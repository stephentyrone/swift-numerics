//===--- Real.swift -------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// A type that models the real numbers.
///
/// Types conforming to this protocol provide the arithmetic and utility
/// operations defined by the `FloatingPoint` protocol, and provide all of the
/// math functions defined by the `ElementaryFunctions` and `RealFunctions`
/// protocols. This protocol does not add any additional conformances itself,
/// but is very useful as a protocol against which to write generic code. For
/// example, we can naturally write a generic implementation of a sigmoid
/// function:
/// ```
/// func sigmoid<T: Real>(_ x: T) -> T {
///   return 1/(1 + .exp(-x))
/// }
/// ```
/// See also `ElementaryFunctions`, `RealFunctions` and `AlgebraicField`.
public protocol Real: FloatingPoint, RealFunctions, AlgebraicField {
}

//  While `Real` does not provide any additional customization points,
//  it does allow us to default the implementation of a few operations,
//  and also provides `signGamma`.
extension Real {
  @_transparent
  public static func exp10(_ x: Self) -> Self {
    return pow(10, x)
  }
  
  /// cos(x) - 1, computed in such a way as to maintain accuracy for small x.
  ///
  /// See also `ElementaryFunctions.expMinusOne()`.
  @inlinable
  public static func cosMinusOne(_ x: Self) -> Self {
    let sinxOver2 = sin(x/2)
    return -2*sinxOver2*sinxOver2
  }
  
  #if !os(Windows)
  @inlinable
  public static func signGamma(_ x: Self) -> FloatingPointSign {
    // Gamma is strictly positive for x >= 0.
    if x >= 0 { return .plus }
    // For negative x, we arbitrarily choose to assign a sign of .plus to the
    // poles.
    let integralPart = x.rounded(.towardZero)
    if x == integralPart { return .plus }
    // Otherwise, signGamma is .minus if the integral part of x is even.
    return integralPart.isEven ? .minus : .plus
  }
  
  //  Determines if this value is even, assuming that it is an integer.
  @inline(__always) @usableFromInline
  internal var isEven: Bool {
    if Self.radix == 2 {
      // For binary types, we can just check if x/2 is an integer. This works
      // because x/2 is always computed exactly.
      let half = self/2
      return half == half.rounded(.towardZero)
    } else {
      // For decimal types, it's not quite that simple, because x/2 is not
      // necessarily computed exactly. As an example, suppose that we had a
      // decimal type with a one digit significand, and self = 7. Then self/2
      // would round to 4, and we would (wrongly) conclude that it was an
      // integer, and hence that self was even.
      //
      // Instead, for decimal types, we check if 2*trunc(self/2) == self,
      // using an FMA; this is always correct; this approach works for any
      // radix, but the previous method is more efficient for radix == 2.
      let half = self/2
      return self.addingProduct(-2, half.rounded(.towardZero)) == 0
    }
  }
  #endif
  
  @_transparent
  public static func sqrt(_ x: Self) -> Self {
    return x.squareRoot()
  }
  
  /// The (approximate) reciprocal (multiplicative inverse) of this number,
  /// if it is representable.
  ///
  /// If `a` if finite and nonzero, and `1/a` overflows or underflows,
  /// then `a.reciprocal` is `nil`. Otherwise, `a.reciprocal` is `1/a`.
  ///
  /// If `b.reciprocal` is non-nil, you may be able to replace division by `b`
  /// with multiplication by this value. It is not advantageous to do this
  /// for an isolated division unless it is a compile-time constant visible
  /// to the compiler, but if you are dividing many values by a single
  /// denominator, this will often be a significant performance win.
  ///
  /// A typical use case looks something like this:
  ///
  /// ```swift
  /// func divide<T: Real>(data: [T], by divisor: T) -> [T] {
  ///   // If divisor is well-scaled, multiply by reciprocal.
  ///   if let recip = divisor.reciprocal {
  ///     return data.map { $0 * recip }
  ///   }
  ///   // Fallback on using division.
  ///   return data.map { $0 / divisor }
  /// }
  /// ```
  ///
  /// Error Bounds:
  ///
  /// Multiplying by the reciprocal instead of dividing will slightly
  /// perturb results. For example `5.0 / 3` is 1.6666666666666667, but
  /// `5.0 * 3.reciprocal!` is 1.6666666666666665.
  ///
  /// The error of a normal division is bounded by half an ulp of the
  /// result; we can derive a quick error bound for multiplication by
  /// the real reciprocal (when it exists) as follows (I will use circle
  /// operators to denote real-number arithmetic, and normal operators
  /// for floating-point arithmetic):
  ///
  /// ```
  /// a * b.reciprocal! = a * (1/b)
  ///                   = a * (1 ⊘ b)(1 + δ₁)
  ///                   = (a ⊘ b)(1 + δ₁)(1 + δ₂)
  ///                   = (a ⊘ b)(1 + δ₁ + δ₂ + δ₁δ₂)
  /// ```
  ///
  /// where `0 < δᵢ <= ulpOfOne/2`. This gives a roughly 1-ulp error,
  /// about twice the error bound we get using division. For most
  /// purposes this is an acceptable error, but if you need to match
  /// results obtained using division, you should not use this.
  @inlinable
  public var reciprocal: Self? {
    let recip = 1/self
    if recip.isNormal || isZero || !isFinite {
      return recip
    }
    return nil
  }
}

// Haven't thought about how these implementations interact with decimal
// types yet, but also we don't have any decimal conformers to RealFunctions
// yet, so that's OK. Need to audit these once we have one.
extension Real where Self: BinaryFloatingPoint {
  
  @inlinable
  public static func acosOverPi(_ x: Self) -> Self { 
    acos(x) / .pi
  }
  
  @inlinable
  public static func asinOverPi(_ x: Self) -> Self {
    asin(x) / .pi
  }
  
  @inlinable
  public static func atanOverPi(_ x: Self) -> Self {
    atan(x) / .pi
  }
  
  @inlinable
  public static func atan2OverPi(y: Self, x: Self) -> Self {
    atan2(y: y, x: x) / .pi
  }
  
  @inlinable
  public static func cos(piTimes x: Self) -> Self {
    // Cosine is even, so all we need is the magnitude.
    let x = x.magnitude
    // If x is not finite, the result is nan.
    guard x.isFinite else { return .nan }
    // If x is finite and at least radix/ulpOfOne, it is an even
    // integer, which means that cos(piTimes: x) is 1.0
    if x >= Self(radix)/ulpOfOne { return 1 }
    // Break x up as x = n/2 + f where n is an integer. In binary, the
    // following computation is always exact, and trivially gives the
    // correct result.
    let n = (2*x).rounded(.toNearestOrEven)
    let f = x.addingProduct(-1/2, n)
    // Because cosine is 2π-periodic, we don't actually care about
    // most of n; we only need the two least significant bits of n
    // represented as an integer:
    let quadrant = n._lowWord & 0x3
    // Select ±sin/±cos depending on quadrant and evaluate at πx.
    // The multiplication by π in native precision introduces up to
    // about an ulp of error (.pi can be up to half an ulp away from
    // the true value of π, and then the multiplication itself rounds,
    // introducing another half-ulp). This error is then magnified by
    // evaluating sin/cos itself (roughly adding however much error
    // those functions have). There is no error in the function before
    // this point, so the total error is roughly 1 + e ulps, where e
    // is the error bound for sin or cos. For any concrete type, we
    // can basically eliminate this error by using an extended-precision
    // representation of π and an extra-precise computation of sin or
    // cos, but in the generic implementation here, we just accept the
    // 1+e error bound.
    switch quadrant {
    case 0: return  cos(.pi * f)
    // Have to fix-up sign of zero for this one case to match the
    // definition of cos(πx); otherwise it would fall out to be -0 here.
    case 1: return f == 0 ? 0 : -sin(.pi * f)
    case 2: return -cos(.pi * f)
    case 3: return  sin(.pi * f)
    default: fatalError()
    }
  }
  
  @inlinable
  public static func sin(piTimes x: Self) -> Self {
    // If x is not finite, the result is nan.
    guard x.isFinite else { return .nan }
    // If x is negative, compute sin(-πx), then flip the sign.
    if x.sign == .minus { return -sin(piTimes: x.magnitude) }
    // If x.magnitude is finite and at least 1/ulpOfOne, it is an
    // integer, which means that sin(piTimes: x) is ±0.0
    if x.magnitude >= 1/ulpOfOne {
      return Self(signOf: x, magnitudeOf: 0)
    }
    // Break x up as x = n/2 + f where n is an integer. In binary, the
    // following computation is always exact, and trivially gives the
    // correct result.
    let n = (2*x).rounded(.toNearestOrEven)
    let f = x.addingProduct(-1/2, n)
    // Because sine is 2π-periodic, we don't actually care about
    // most of n; we only need the two least significant bits of n
    // represented as an integer:
    let quadrant = n._lowWord & 0x3
    switch quadrant {
    case 0: return  sin(.pi * f)
    case 1: return  cos(.pi * f)
    case 2: return f == 0 ? 0 : -sin(.pi * f)
    case 3: return -cos(.pi * f)
    default: fatalError()
    }
  }
  
  @inlinable
  public static func tan(piTimes x: Self) -> Self {
    return sin(piTimes: x)/cos(piTimes: x)
  }
}

// MARK: Implementation details
extension Real where Self: BinaryFloatingPoint {
  /// The low-order word of the floor of this value.
  ///
  /// Traps if the value is not finite.
  @_transparent
  public var _lowWord: UInt {
    // If magnitude is small enough, we can simply convert to Int64 and then
    // wrap to UInt.
    if magnitude < 0x1.0p63 {
      return UInt(truncatingIfNeeded: Int64(self.rounded(.down)))
    }
    precondition(isFinite)
    // Clear any bits above bit 63; the result of this expression is
    // strictly in the range [0, 0x1p64). (Note that if we had not eliminated
    // small magnitudes already, the range would include tiny negative values
    // which would then produce the wrong result; the branch above is not
    // only for performance.
    let cleared = self - 0x1p64*(self * 0x1p-64).rounded(.down)
    // Now we can unconditionally convert to UInt64, and then wrap to UInt.
    return UInt(truncatingIfNeeded: UInt64(cleared))
  }
}
