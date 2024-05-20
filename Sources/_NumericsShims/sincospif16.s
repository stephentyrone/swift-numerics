//===--- sincospif16.s -------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

#if __APPLE__ && __arm64__
// This file defines the following entrypoints:
// - swift_cospif16: Computes cos(πx) correctly-rounded¹ in Float16.
.globl _swift_cospif16
// - swift_sinpif16: Computes sin(πx) correctly-rounded¹ in Float16.
.globl _swift_sinpif16
// ----------------
// ¹ Assuming default rounding; if a non-default rounding-mode is active,
//   the result may have an error of up to 1+ε ULP for some quite-small ε.


//  TODO: Adapt symbol mangling and assembly syntax and directives as needed
//  to work on non-Apple targets.

.text
.p2align 6
//  cos(πx) and sin(πx) share almost all of their implementation, because one
//  is just a phase shift of the other. There are three details that we have
//  to account for before jumping into the shared code:
//  1. The phase--we put an integer bias of 0 (cos) or -1 (sin) in s1 to
//     provide the necessary phase shift.
//  2. When the result is exactly zero, the polynomials that we use to compute
//     cos(πx) and sin(πx) do not naturally produce zeros with the sign chosen
//     by IEEE 754. We put the bit pattern of the correct zero result in w1.
//  3. The fifth- and sixth-order polynomials that we use in the shared core
//     are good enough to deliver a correctly-rounded result for cos(πx), but
//     not for sin(πx) when x is in (-0.25, 0.25) (no fifth-order polynomial
//     can do so¹). Therefore when |x| < 0.25, we branch to a separate routine
//     that uses a seventh-order polynomial instead.
//
//  ¹ at least, no purely-odd fifth-order polynomial.
_swift_cospif16:
    mov     w1,        wzr  // sign of zero result is always positive.
    eor.8b  v2,     v2, v2  // no bias for phase when computing cosine.
    b       Lsincospif16Core

.p2align 4
_swift_sinpif16:
    fmov    w0,         s0
    and     w1,     w0, #0x8000 // sign of zero result matches sign of x.
    ubfx    w0,     w0, #10, #5 // biased exponent of x
    cmp     w0,         #13
    b.lo    Lsinpif16SmallInput
//  |x| is not smaller than 0.25. Bias phase by -1 to compute sine.
    cmeq.2s v1,     v1, v1

Lsincospif16Core:
//  Convert to Float, and reduce 2x = n + f, where n is an integer and f is
//  in [-0.5, 0.5]. Then apply the phase bias from v1 to n, so that cosine
//  and sine can share the implementation from here onward.
    fcvt    s0,         h0
    fadd    s2,     s0, s0  // 2x
    fcvtns  s0,         s2  // n as Int32
    frintn  s3,         s2  // n as Float
    add.2s  v0,     v0, v1  // apply phase bias to n
    fsub    s1,     s2, s3  // f as Float
//  The result returned is a Float16 computed as follows:
//
//    switch n & 3 {
//      case 0:  cos(πf/2)
//      case 1: f == 0 ? z : -sin(πf/2)
//      case 2: -cos(πf/2)
//      case 3: f == 0 ? z :  sin(πf/2)
//    }
//
//  We evaluate all four cases simultaneously in four SIMD lanes; case 0 in
//  lane 0, case 3 in lane 3. We'll select the appropriate result when we're
//  done.
    fmul    s2,     s1, s1    // f²
    adrp    x0,         sincospif16_constants@PAGE
    add     x0,     x0, sincospif16_constants@PAGEOFF
    ldp     q4,q5, [x0]
    fmla.4s v5,     v4, v2[0]
    ldp     q4,q6, [x0,#32]
    fmla.4s v4,     v5, v2[0]
//  For the final FMA, we have to build the vector [f²  f  f²  f] to multiply
//  by, because cosine is even and sine is odd.
    ldr     q5,    [x0,#64]
    tbl.16b v2,    {v1,v2},v5 // [ f²  f   f²  f ]
    fmla.4s v6,     v4, v2    // [ c  -s  -c   s ]
//  Currently the result (up to the sign of zero) is in v6[n & 3]. Extract
//  that element and put it in s0.
    bic.2s  v0,         #0xfc
    shl.8b  v0,     v0, #2
    dup.8b  v0,         v0[0]
    ldr     s5,    [x0,#68]
    add.8b  v0,     v0, v5
    tbl.8b  v0,    {v6},v0
//  Round to Float16 and fixup the sign of zero results.
    fcmeq.2s v5,    v0, #0.0  // result == 0
    fcvt    h0,         s0    // Float16(result)
    fmov    s1,         w1
    bit.8b  v0,     v1, v5
    ret

Lsinpif16SmallInput:
//  Seventh-order polynomial approximation
    fcvt    s0,         h0
    adrp    x0,         sinpif16Small_constants@PAGE
    add     x0,     x0, sinpif16Small_constants@PAGEOFF
    fmul    s1,     s0, s0      // x²
    ldp     s2, s3,    [x0]     // s₇ s₅
    fmadd   s4, s1, s2, s3      // s₅ + s₇x²
    ldp     s2, s3,    [x0, #8] // s₃ s₁
    fmadd   s4, s1, s4, s2      // s₃ + s₅x² + s₇x⁴
    fmadd   s4, s1, s4, s3      // s₁ + s₃x² + s₅x⁴ + s₇x⁶
    fmul    s0,     s4, s0      // s₁x + s₃x³ + s₅x⁵ + s₇x⁷
    fcvt    h0,         s0      // sin(πx)
    ret

.const_data
.p2align 6
//  The following are the coefficients for polynomials that provide correctly-
//  rounded approximations to cos(πx/2) and sin(πx/2) on [-0.5, 0.5]. (Note
//  that the sin polynomial is _only correctly rounded when used on a reduced
//  input to cos(πx); if you try to use it to implement sin(πx/2) directly it
//  will not produce correctly-rounded results for some inputs).
//
//  Note that these polynomial approximations are correctly-rounded for
//  Float16 whether they are evaluated with separate mul-add or with fma.
//
//  (Thanks to Tor Myklebust for providing the approximation to sin(πx/2),
//  which is especially finicky.)
sincospif16_constants:
//        cos(πx/2)      -sin(πx/2)      -cos(πx/2)       sin(πx/2)
.float -0x1.4eabcap-6, -0x1.40cc40p-4,  0x1.4eabcap-6,  0x1.40cc40p-4  // 6th / 5th order terms
.float  0x1.03b17ap-2,  0x1.4aac48p-1, -0x1.03b17ap-2, -0x1.4aac48p-1  // 4th / 3rd
.float -0x1.3bd3a2p+0, -0x1.921f72p+0,  0x1.3bd3a2p+0,  0x1.921f72p+0  // 2nd / 1st
.float  1.0,            0.0          , -1.0,            0.0            // 0th
//  TBL mask used to select between [f and f²] for the last multiply-add in
//  the polynomial evaluation.
.byte  16, 17, 18, 19,  0,  1,  2,  3, 16, 17, 18, 19,  0,  1,  2,  3
//  Coefficients for a seventh-order polynomial used to evaluate sin(πx)
//  on [-0.25, 0.25].
sinpif16Small_constants:
.float -0x1.2f0f08p-1,  0x1.466984p+1, -0x1.4abbe8p+2,  0x1.921fb6p+1
#endif
