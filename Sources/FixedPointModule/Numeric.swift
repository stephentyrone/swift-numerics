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

extension FixedPoint where IntegerType: UnsignedInteger {
  public typealias Magnitude = Self
  @_transparent
  public var magnitude: Self { self }
}

extension FixedPoint where IntegerType: SignedInteger {
  public typealias Magnitude = FixedPointMagnitude<Self>
  @_transparent
  public var magnitude: FixedPointMagnitude<Self> {
    FixedPointMagnitude(bitPattern: self.bitPattern.magnitude)
  }
}

extension FixedPoint {
  @inlinable
  public static func *(a: Self, b: Self) -> Self {
    let (hi, lo) = a.bitPattern.multipliedFullWidth(by: b.bitPattern)
    // TODO: round to nearest??? This floors, which is default expectation
    // for fixed-point, but less accurate and maybe a less-good default
    // behavior.
    let bitsFromLo = IntegerType(truncatingIfNeeded: lo >> fractionBits)
    let bitsFromHi = hi &<< (IntegerType.bitWidth - fractionBits)
    // TODO: trap on overflow instead of wrapping
    return Self(bitPattern: bitsFromHi | bitsFromLo)
  }
  
  @_transparent
  public static func *=(a: inout Self, b: Self) {
    a = a * b
  }
  
  @inlinable
  public static func /(a: Self, b: Self) -> Self {
    let hi = a.bitPattern &>> (IntegerType.bitWidth - fractionBits)
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
