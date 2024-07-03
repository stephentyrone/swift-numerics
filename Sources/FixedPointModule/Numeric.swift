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
    FixedPointMagnitude(bitPattern: self.bitPattern.magnitude)
  }
}

extension FixedPoint where IntegerType: UnsignedInteger {
  
  public typealias Magnitude = Self
  
  @_transparent
  public var magnitude: Self { self }
}

// TODO: consider rounding semantics of * and /: * floors and / truncates
// They should at least match (flooring), but arguably it would be better
// if both rounded.

extension FixedPoint {
  @inlinable
  public static func *(a: Self, b: Self) -> Self {
    let round = IntegerType.Magnitude(1) << (fractionBits - 1)
    let product = IntegerType.fullMultiply(a.bitPattern, b.bitPattern, adding: round)
    let bitsFromLo = IntegerType(truncatingIfNeeded: product.low >> fractionBits)
    let bitsFromHi = product.high &<< integralBits
    return Self(bitPattern: bitsFromHi | bitsFromLo)
  }
  
  @_transparent
  public static func *=(a: inout Self, b: Self) {
    a = a * b
  }
  
  @inlinable
  public static func /(a: Self, b: Self) -> Self {
    let hi = a.bitPattern &>> integralBits
    let lo = IntegerType.Magnitude(truncatingIfNeeded: a.bitPattern) << fractionBits
    // TODO: enforce trap on overflow, consider rounding to nearest
    return Self(bitPattern:
      b.bitPattern.dividingFullWidth((hi, lo)).quotient
    )
  }
  
  @_transparent
  public static func /=(a: inout Self, b: Self) {
    a = a / b
  }
}

extension FixedPoint {
  @_transparent
  public static func &*(a: Self, b: Self) -> Self {
    let (hi, lo) = a.bitPattern.multipliedFullWidth(by: b.bitPattern)
    let bitsFromLo = IntegerType(truncatingIfNeeded: lo >> fractionBits)
    let bitsFromHi = hi &<< (IntegerType.bitWidth - fractionBits)
    return Self(bitPattern: bitsFromHi | bitsFromLo)
  }
  
  @_transparent
  public static func &*=(a: inout Self, b: Self) {
    a = a &* b
  }
}
