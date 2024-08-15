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
    rounding rule: RoundingRule = .toNearestOrUp
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
  /// The specified floating-point `value` rounded to a representable
  /// fixed-point number according to `rule`.
  ///
  /// For example, suppose we have a signed eight-bit FixedPoint format
  /// with three fraction bits:
  /// ```
  /// struct Int8Q3: FixedPoint {
  ///   public var bitPattern: Int8
  ///   public static var fractionBits: Int { 3 }
  ///   public init(bitPattern: Int8) {
  ///     self.bitPattern = bitPattern
  ///   }
  /// }
  /// ```
  /// and suppose we initialize it from the Float value `1.2`, rounding down:
  /// ```
  /// let float: Float = 1.2
  /// let fixed = Int8Q3(float, rounding: .down)
  /// ```
  /// the two closest representable values are `1.125` (bitPattern
  /// `0b00001.001`) and `1.25` (bitPattern `0b00001.010`). Because we
  /// specified rounding _down_, the smaller of the two is chosen, and the
  /// result is `1.125`.
  ///
  /// If, after rounding, the value would be outside the range representable
  /// in the fixed-point type, a precondition failure occurs. Thus:
  /// ```
  /// // rounds to 15.875, which is Int8Q3.max
  /// let fine = Int8Q3(15.9, rounding: .down)
  /// // would round to 16.0, which is not representable
  /// let trap = Int8Q3(15.94, rounding: .toNearestOrUp)
  /// ```
  ///
  /// > See also:
  /// If you need to avoid trapping on out-of-range values, consider using
  /// ``init(clamping:rounding:)`` or ``init(ifRepresentable:rounding:)``
  @inlinable
  public init<Other: BinaryFloatingPoint>(
    _ value: Other,
    rounding rule: RoundingRule = .toNearestOrEven
  ) {
    self = Self(ifRepresentable: value, rounding: rule)!
  }
  
  /// The specified floating-point `value` rounded to a representable
  /// fixed-point number according to `rule`, and clamping any out-of-range
  /// values to the representable range.
  ///
  /// If `init(value, rounding:rule)` succeeds, then
  /// `init(clamping:value, rounding:rule)` produces the same result.
  /// However, if value is not in the representable range of the fixed-point
  /// format after rounding, the first init will have a precondition failure,
  /// while the `clamping:` init will return `.max` (if value is positive)
  /// or `.min` (if it is not).
  ///
  /// > See also:
  /// ``/FixedPoint/init(_:rounding:)-67pr9`` and ``init(ifRepresentable:rounding:)``
  @inlinable
  public init<Other: BinaryFloatingPoint>(
    clamping value: Other,
    rounding rule: RoundingRule = .toNearestOrEven
  ) {
    if let fixed = Self(ifRepresentable: value, rounding: rule) {
      self = fixed
    } else {
      self.init(bitPattern: value > 0 ? .max : .min)
    }
  }
  
  /// The specified floating-point `value` rounded to a representable
  /// fixed-point number according to `rule`, returning `nil` if the value
  /// is out-of-range after rounding.
  ///
  /// If `init(value, rounding:rule)` succeeds, then
  /// `init(ifRepresentable:value, rounding:rule)` produces the same result.
  /// However, if value is not in the representable range of the fixed-point
  /// format after rounding, the first init will have a precondition failure,
  /// while the `ifRepresentable:` init will return `nil`.
  ///
  /// > See also:
  /// ``/FixedPoint/init(_:rounding:)-67pr9`` and ``init(clamping:rounding:)``
  @inlinable
  public init?<Other: BinaryFloatingPoint>(
    ifRepresentable value: Other,
    rounding rule: RoundingRule = .toNearestOrEven
  ) {
    Self.invariantCheck()
    let scale = Other(
      sign: .plus,
      exponent: Other.Exponent(Self.fractionBits),
      significand: 1
    )
    let rounded = (scale * value).rounding(rule)
    guard let maybeBitPattern = IntegerType(exactly: rounded) else {
      return nil
    }
    self.init(bitPattern: maybeBitPattern)
  }
  
  @inlinable
  public init?<Other: BinaryFloatingPoint>(
    exactly other: Other
  ) {
    Self.invariantCheck()
    let scale = Other(
      sign: .plus,
      exponent: Other.Exponent(Self.fractionBits),
      significand: 1
    )
    guard let bitPattern = IntegerType(exactly: scale * other) else {
      return nil
    }
    self.init(bitPattern: bitPattern)
  }
}
