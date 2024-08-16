//===--- Numeric.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import IntegerUtilities

extension FixedPoint where IntegerType: SignedInteger {
  
  public typealias Magnitude = FixedPointMagnitude<Self>
  
  @_transparent
  public var magnitude: FixedPointMagnitude<Self> {
    FixedPointMagnitude(bitPattern: bitPattern.magnitude)
  }
}

extension FixedPoint where IntegerType: UnsignedInteger {
  
  public typealias Magnitude = Self
  
  @_transparent
  public var magnitude: Self { self }
}

extension FixedPoint {
  @inlinable
  public func multipliedReportingOverflow(
    by other: Self,
    rounding rule: RoundingRule = Self.defaultRounding
  ) -> (wrappedValue: Self, overflow: Bool) {
    
    var prod = bitPattern.multipliedFullWidth(by: other.bitPattern)
    func roundViaAddition(_ addend: IntegerType.Magnitude) {
      let (low, carry) = prod.low.addingReportingOverflow(addend)
      let high = prod.high &+ (carry ? 1 : 0)
      prod = (high, low)
    }
    
    let frac = IntegerType.Magnitude(truncatingIfNeeded: Self.fractionMask)
    let unit = IntegerType.Magnitude(truncatingIfNeeded: Self.unit)
    let half = IntegerType.Magnitude(truncatingIfNeeded: Self.half)
    let sign = IntegerType.Magnitude(truncatingIfNeeded: prod.high.signbit)
    
    switch rule {
    case .down: break
    case .up:
      roundViaAddition(frac)
    case .towardZero:
      roundViaAddition(frac & sign)
    case .awayFromZero:
      roundViaAddition(frac & ~sign)
    case .toOdd:
      if Self.fractionBits == IntegerType.bitWidth {
        prod.high |= prod.low == 0 ? 0 : 1
      } else {
        prod.low |= (prod.low &+ frac) & unit
      }
    case .toNearestOrDown:
      roundViaAddition(half &- 1)
    case .toNearestOrUp:
      roundViaAddition(half)
    case .toNearestOrZero:
      roundViaAddition(half &- 1 &- sign)
    case .toNearestOrAway:
      roundViaAddition(half &+ sign)
    case .toNearestOrEven:
      let parity: IntegerType.Magnitude
      if Self.fractionBits == IntegerType.bitWidth {
        parity = IntegerType.Magnitude(truncatingIfNeeded: prod.high) & 1
      } else {
        parity = prod.low >> Self.fractionBits & 1
      }
      roundViaAddition(half &- 1 &+ parity)
    case .stochastically:
      roundViaAddition(.random(in: 0 ... frac))
    case .requireExact:
      guard prod.low & frac == 0 else {
        preconditionFailure("Multiplication is not exact.")
      }
    }
    let bitsFromLo = IntegerType(truncatingIfNeeded: prod.low >> Self.fractionBits)
    let bitsFromHi = prod.high &<< Self.integralBits
    let lostBits = prod.high >> (Self.fractionBits - (IntegerType.isSigned ? 1 : 0))
    let overflow = lostBits != prod.high.signbit
    return (Self(bitPattern: bitsFromHi | bitsFromLo), overflow)
  }
  
  @_transparent
  public static func *(a: Self, b: Self) -> Self {
    guard case let (result, false) = a.multipliedReportingOverflow(by: b) else {
      preconditionFailure("Multiplication \(a)*\(b) overflows.")
    }
    return result
  }
  
  @_transparent
  public static func *=(a: inout Self, b: Self) {
    a = a * b
  }
  
  @_transparent
  public static func &*(a: Self, b: Self) -> Self {
    return a.multipliedReportingOverflow(by: b).wrappedValue
  }
  
  @_transparent
  public static func &*=(a: inout Self, b: Self) {
    a = a &* b
  }
  
  /// The quotient produced dividing this value by `other`, rounding according
  /// to the specified `rule`, if it is representable.
  ///
  /// If the result is not representable, because one of the following criteria
  /// hold:
  /// - the divisor is zero
  /// - the quotient would overflow
  /// - the quotient is not exact and the rounding rule is `.requireExact`
  /// then the result is `nil`.
  @inlinable
  public func dividedIfRepresentable(
    by other: Self,
    rounding rule: RoundingRule = Self.defaultRounding
  ) -> Self? {
    let hi = bitPattern &>> Self.integralBits
    let lo = IntegerType.Magnitude(truncatingIfNeeded: bitPattern) << Self.fractionBits
    if let quotient = other.bitPattern.dividing((hi, lo), rounding: rule) {
      return Self(bitPattern: quotient)
    }
    return nil
  }
  
  @_transparent
  public static func /(a: Self, b: Self) -> Self {
    guard let result = a.dividedIfRepresentable(by: b) else {
      preconditionFailure("Division \(a)/\(b) overflows.")
    }
    return result
  }
  
  @_transparent
  public static func /=(a: inout Self, b: Self) {
    a = a / b
  }
}
