//===--- SaturatingArithmetic.swift ---------------------------*- swift -*-===//
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

extension FixedPoint {
  /// Saturating fixed-point addition
  ///
  /// `self + other` clamped to the representable range of the type. If the
  /// "normal addition" `self - other` does not trap, that result is returned.
  /// Otherwise, `addingWithSaturation` produces either `.min` (if the
  /// true result would be less than `.min`) or `.max` (if the true result
  /// would be greater than `.max`).
  @_transparent
  public func addingWithSaturation(_ other: Self) -> Self {
    Self(bitPattern: self.bitPattern.addingWithSaturation(other.bitPattern))
  }
  
  /// Saturating fixed-point subtraction
  ///
  /// `self - other` clamped to the representable range of the type. If the
  /// "normal subtraction" `self - other` does not trap, that result is
  /// returned. Otherwise, `subtractingWithSaturation` produces either `.min`
  /// (if the true result would be less than `.min`) or `.max` (if the true
  /// result would be greater than `.max`).
  @_transparent
  public func subtractingWithSaturation(_ other: Self) -> Self {
    Self(bitPattern: self.bitPattern.subtractingWithSaturation(other.bitPattern))
  }
  
  /// Saturating fixed-point negation
  ///
  /// For unsigned types, the result is always zero. This is not very
  /// interesting, but may occasionally be useful in generic contexts.
  /// For signed types, the result is `-self` unless `self` is `.min`,
  /// in which case the result is `.max`.
  @_transparent
  public func negatedWithSaturation() -> Self {
    Self(bitPattern: self.bitPattern.negatedWithSaturation())
  }
  
  /// Saturating fixed-point multiplication
  ///
  /// `self * other` clamped to the representable range of the type. If the
  /// "normal subtraction" `self * other` does not trap, that result is
  /// returned. Otherwise, `multipliedWithSaturation` produces either `.min`
  /// (if the true result would be less than `.min`) or `.max` (if the true
  /// result would be greater than `.max`).
  @_transparent
  public func multipliedWithSaturation(
    by other: Self,
    rounding rule: RoundingRule = Self.defaultRounding
  ) -> Self {
    let (result, overflow) = self.multipliedReportingOverflow(by: other, rounding: rule)
    if !overflow { return result }
    return Self(
      bitPattern: .max &- (self.bitPattern ^ other.bitPattern).signbit
    )
  }
}
