//===--- Float16+Real.swift -----------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import _NumericsShims

// Float16 is only available on macOS when targeting arm64.
#if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))

#if arch(arm64)
import _Builtin_intrinsics.arm.neon
#endif

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
extension Float16: Real {
  @_transparent
  public static func cos(_ x: Float16) -> Float16 {
    Float16(.cos(Float(x)))
  }
  
  @_transparent
  public static func sin(_ x: Float16) -> Float16 {
    Float16(.sin(Float(x)))
  }
  
  @_transparent
  public static func tan(_ x: Float16) -> Float16 {
    Float16(.tan(Float(x)))
  }
  
  @_transparent
  public static func acos(_ x: Float16) -> Float16 {
    Float16(.acos(Float(x)))
  }
  
  @_transparent
  public static func asin(_ x: Float16) -> Float16 {
    Float16(.asin(Float(x)))
  }
  
  @_transparent
  public static func atan(_ x: Float16) -> Float16 {
    Float16(.atan(Float(x)))
  }
  
  @_transparent
  public static func cosh(_ x: Float16) -> Float16 {
    Float16(.cosh(Float(x)))
  }
  
  @_transparent
  public static func sinh(_ x: Float16) -> Float16 {
    Float16(.sinh(Float(x)))
  }
  
  @_transparent
  public static func tanh(_ x: Float16) -> Float16 {
    Float16(.tanh(Float(x)))
  }
  
  @_transparent
  public static func acosh(_ x: Float16) -> Float16 {
    Float16(.acosh(Float(x)))
  }
  
  @_transparent
  public static func asinh(_ x: Float16) -> Float16 {
    Float16(.asinh(Float(x)))
  }
  
  @_transparent
  public static func atanh(_ x: Float16) -> Float16 {
    Float16(.atanh(Float(x)))
  }
  
  @_transparent
  public static func exp(_ x: Float16) -> Float16 {
    Float16(.exp(Float(x)))
  }
  
  @_transparent
  public static func expMinusOne(_ x: Float16) -> Float16 {
    Float16(.expMinusOne(Float(x)))
  }
  
  @_transparent
  public static func log(_ x: Float16) -> Float16 {
    Float16(.log(Float(x)))
  }
  
  @_transparent
  public static func log(onePlus x: Float16) -> Float16 {
    Float16(.log(onePlus: Float(x)))
  }
  
  @_transparent
  public static func erf(_ x: Float16) -> Float16 {
    Float16(.erf(Float(x)))
  }
  
  @_transparent
  public static func erfc(_ x: Float16) -> Float16 {
    Float16(.erfc(Float(x)))
  }
  
  @_transparent
  public static func exp2(_ x: Float16) -> Float16 {
    Float16(.exp2(Float(x)))
  }
  
  @_transparent
  public static func exp10(_ x: Float16) -> Float16 {
    Float16(.exp10(Float(x)))
  }
  
  @_transparent
  public static func hypot(_ x: Float16, _ y: Float16) -> Float16 {
    if x.isInfinite || y.isInfinite { return .infinity }
    let xf = Float(x)
    let yf = Float(y)
    return Float16(.sqrt(xf*xf + yf*yf))
  }
  
  @_transparent
  public static func gamma(_ x: Float16) -> Float16 {
    Float16(.gamma(Float(x)))
  }
  
  @_transparent
  public static func log2(_ x: Float16) -> Float16 {
    Float16(.log2(Float(x)))
  }
  
  @_transparent
  public static func log10(_ x: Float16) -> Float16 {
    Float16(.log10(Float(x)))
  }
  
  @_transparent
  public static func pow(_ x: Float16, _ y: Float16) -> Float16 {
    Float16(.pow(Float(x), Float(y)))
  }
  
  @_transparent
  public static func pow(_ x: Float16, _ n: Int) -> Float16 {
    // Float16 is simpler than Float or Double, because the range of
    // "interesting" exponents is pretty small; anything outside of
    // -22707 ... 34061 simply overflows or underflows for every
    // x that isn't zero or one. This whole range is representable
    // as Float, so we can just use powf as long as we're a little
    // bit (get it?) careful to preserve parity.
    let clamped = min(max(n, -0x10000), 0x10000) | (n & 1)
    return Float16(libm_powf(Float(x), Float(clamped)))
  }
  
  @_transparent
  public static func root(_ x: Float16, _ n: Int) -> Float16 {
    Float16(.root(Float(x), n))
  }
  
  @_transparent
  public static func atan2(y: Float16, x: Float16) -> Float16 {
    Float16(.atan2(y: Float(y), x: Float(x)))
  }
  
  #if !os(Windows)
  @_transparent
  public static func logGamma(_ x: Float16) -> Float16 {
    Float16(.logGamma(Float(x)))
  }
  #endif
  
  // TODO: once clang stabilizes the calling conventions for _Float16 on Intel,
  // we can re-enable these; presently the type is disabled on the target.
  #if !(arch(i386) || arch(x86_64))
  @_transparent
  public static func _relaxedAdd(_ a: Float16, _ b: Float16) -> Float16 {
    _numerics_relaxed_addf16(a, b)
  }
  
  @_transparent
  public static func _relaxedMul(_ a: Float16, _ b: Float16) -> Float16 {
    _numerics_relaxed_mulf16(a, b)
  }
  #endif
  
#if arch(arm64) && canImport(Darwin)
  // MARK: - assembly shims
  @_transparent
  public static func cos(piTimes x: Float16) -> Float16 {
    swift_cospif16(x)
  }
  
  @_transparent
  public static func sin(piTimes x: Float16) -> Float16 {
    swift_sinpif16(x)
  }
#else
  // MARK: - complete Swift implementations
  public static func cos(piTimes x: Float16) -> Float16 {
    //  We shouldn't need this; infinity/nan x would simply flow through the
    //  function and produce nan naturally, except for the Int(n) conversion
    //  in reduce(piTimes:), which traps on the out-of-range input (n is nan
    //  if x is not finite).
    //
    //  Fixing this without introducing undefined behavior requires the LLVM
    //  freeze instruction (which allows us to say "pick any value and use
    //  that, but don't allow undefinedness to propagate). However, that isn't
    //  exposed yet via Swift.Builtin,¹ so for now we keep this check around.
    //
    //  ¹ https://github.com/apple/swift/pull/73519 will make it available
    //    in the future.
    guard x.isFinite else { return .nan }
    //  (n, f) such that 2x = n + f exactly, with n an integer and f in
    //  -0.5...0.5.
    let (n, f) = reduce(piTimes: x)
    //  Compute all four of [cos(πf/2),-sin(πf/2),-cos(πf/2), sin(πf/2)]
    //  simultaneously.
    let r = trigPiCore(f)
    //  Select the appropriate result based on the low-order two bits of n.
    return Float16(r[n & 3])
  }
  
  public static func sin(piTimes x: Float16) -> Float16 {
    //  sin(πx) is a little bit different from cos(πx) because the fifth-order
    //  polynomial used in trigPiCore isn't accurate enough for sin when the
    //  original argument is close to zero (you can never hit those bad points
    //  when computing cos(πx), so there's no problem there). Thus, we must
    //  an extra-precise approximation for x in -0.5 ... 0.5.
    if (x.bitPattern & 0x7fff) &- 0x3400 >= 0x4800 {
      guard x.isFinite else { return .nan }
      return sinPiSmall(x)
    }
    //  Having eliminated that case, we now compute sin(πx) exactly like
    //  cos(πx); it's odd instead of even, so we need to set aside the signbit
    //  to apply later, but everything else is pretty much the same.
    let sign = x.bitPattern & 0x8000
    let x = x.magnitude
    //  (n, f) such that 2x = n + f exactly, with n an integer and f in
    //  -0.5...0.5.
    let (n, f) = reduce(piTimes: x)
    //  Compute all four of [cos(πf/2),-sin(πf/2),-cos(πf/2), sin(πf/2)]
    //  simultaneously.
    let r = trigPiCore(f)
    //  Select the appropriate result based on the low-order two bits of n.
    return Float16(bitPattern: Float16(r[(n-1) & 3]).bitPattern ^ sign)
  }
  
  /// (n, f) such that 2x = n + f exactly, with n an integer and f in
  /// -0.5...0.5.
  ///
  /// Nothing in this reduction requires any extra precision; we convert to
  /// Float early just so we don't need to worry about overflow when computing
  /// 2x, but it would also be viable to detect |x| >= 2¹¹ earlier, since
  /// those values are all even integers (and therefore trivial for sin(πx)
  /// and cos(πx)).
  static func reduce(piTimes x: Float16) -> (Int, Float) {
    let x = Float(x)
    let n = (2*x).rounded(.toNearestOrEven)
    let f = (2*x) - n
    return (Int(n), f)
  }
  
  static func trigPiCore(_ x: Float) -> SIMD4<Float> {
    let c₃ = SIMD4<Float>(-0x1.4eabcap-6, -0x1.40cc40p-4,  0x1.4eabcap-6,  0x1.40cc40p-4)
    let c₂ = SIMD4<Float>( 0x1.03b17ap-2,  0x1.4aac48p-1, -0x1.03b17ap-2, -0x1.4aac48p-1)
    let c₁ = SIMD4<Float>(-0x1.3bd3a2p+0, -0x1.921f72p+0,  0x1.3bd3a2p+0,  0x1.921f72p+0)
    let c₀ = SIMD4<Float>( 1, 0,-1, 0)
    let x² = x*x
    let x²orX = SIMD4<Float>(x², x, x², x)
    //  These polynomials are correctly-rounded whether they are evaluated
    //  with separate mul-add or with fma.
#if arch(arm64)
    //  FMA is unconditionally available on arm64, and generally faster than
    //  separate multiply and add.
    return vfmaq_f32(c₀, vfmaq_n_f32(c₁, vfmaq_n_f32(c₂, c₃, x²), x²), x²orX)
#else
    return c₀ + x²orX*(c₁ + x²*(c₂ + x²*c₃))
#endif
  }
  
  static func sinPiSmall(_ x: Float16) -> Float16 {
    let c₇: Float = -0x1.2f0f08p-1
    let c₅: Float =  0x1.466984p+1
    let c₃: Float = -0x1.4abbe8p+2
    let c₁: Float =  0x1.921fb6p+1
    let x = Float(x)
    let x² = x*x
    var r = Relaxed.multiplyAdd(x², c₇, c₅)
    r = Relaxed.multiplyAdd(x², r, c₃)
    r = Relaxed.multiplyAdd(x², r, c₁)
    return Float16(x*r)
  }
#endif
}

#endif
