//===--- Initializers.swift -----------------------------------*- swift -*-===//
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

// MARK: ExpressibleByFloatLiteral
extension FixedPoint {
  @inlinable
  public init(floatLiteral value: Double) {
    Self.invariantCheck()
    self.init(value, rounding: .toNearestOrEven)
  }
}

// MARK: - Inits from other FixedPoint formats
extension FixedPoint {
  @inlinable
  public init<Other: FixedPoint>(
    _ other: Other,
    rounding rule: RoundingRule = .toNearestOrEven
  ) {
    Self.invariantCheck()
    let shift = Other.fractionBits - Self.fractionBits
    if Other.IntegerType.bitWidth > Self.IntegerType.bitWidth {
      self.init(bitPattern: IntegerType(
        other.bitPattern.shifted(rightBy: shift, rounding: rule)
      ))
    } else {
      self.init(bitPattern: IntegerType(other.bitPattern).shifted(
        rightBy: shift, rounding: rule
      ))
    }
  }
}
 
// MARK: - Inits from BinaryFloatingPoint
extension FixedPoint {
  @inlinable
  public init<Other: BinaryFloatingPoint>(
    _ other: Other,
    rounding rule: RoundingRule = .toNearestOrEven
  ) {
    Self.invariantCheck()
    let scale = Other(
      sign: .plus,
      exponent: Other.Exponent(Self.fractionBits),
      significand: 1
    )
    switch rule {
    case .down:
      self = Self(bitPattern: IntegerType((scale * other).rounded(.down)))
    case .up:
      self = Self(bitPattern: IntegerType((scale * other).rounded(.up)))
    case .towardZero: 
      self = Self(bitPattern: IntegerType((scale * other).rounded(.towardZero)))
    case .toNearestOrEven: 
      self = Self(bitPattern: IntegerType((scale * other).rounded(.toNearestOrEven)))
    case .toNearestOrAwayFromZero:
      self = Self(bitPattern: IntegerType((scale * other).rounded(.toNearestOrAwayFromZero)))
    case .awayFromZero:
      if other > 0 {
        self = Self(bitPattern: IntegerType((scale * other).rounded(.up)))
      } else {
        self = Self(bitPattern: IntegerType((scale * other).rounded(.down)))
      }
    case .toOdd:
      let scaled = scale * other
      let rounded = scaled.rounded(.down)
      let sticky: IntegerType = rounded == scaled ? 1 : 0
      self = Self(bitPattern: IntegerType(rounded) | sticky)
    case .toNearestOrUp:
      self = Self(bitPattern: IntegerType(
        Other(0.5).nextUp.addingProduct(scale, other).rounded(.down)
      ))
    case .stochastically:
      fatalError()
    case .requireExact:
      let scaled = scale * other
      let rounded = scaled.rounded(.down)
      precondition(scaled == rounded)
      self = Self(bitPattern: IntegerType(rounded))
    }
  }
  
  @inlinable
  public init?<Other: BinaryFloatingPoint>(
    exactly other: Other,
    rounding rule: FloatingPointRoundingRule = .toNearestOrEven
  ) {
    Self.invariantCheck()
    let scale = Other(
      sign: .plus,
      exponent: Other.Exponent(Self.fractionBits),
      significand: 1
    )
    guard let integer = IntegerType(exactly: (scale * other).rounded(rule)) else {
      return nil
    }
    self = Self(bitPattern: integer)
  }
}

// MARK: - BinaryFloatingPoint initializers
extension BinaryFloatingPoint {
  @inlinable
  public init<Fixed: FixedPoint>(_ other: Fixed) {
    // TODO: make this work for cases where other.bitPattern overflows Self
    // even though the actual value of other is in-range.
    self.init(
      sign: .plus,
      exponent: Self.Exponent(-Fixed.fractionBits),
      significand: Self(other.bitPattern)
    )
  }
  
  @inlinable
  public init?<Fixed: FixedPoint>(exactly other: Fixed) {
    fatalError()
  }
}
