//===--- Rounding.swift ---------------------------------------*- swift -*-===//
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
  
  /// Round to an integral value, according to the sepecified `RoundingRule`.
  ///
  /// The result has the same type as the input; it is still in the fixed-point
  /// format, but always has integral value. If rounding to an integral value
  /// in the specified direction results in overflow, a precondition failure
  /// occurs.
  ///
  /// > Note:
  ///   You can avoid precondition failures on overflow using
  ///   ``roundingIfRepresentable(_:)`` and ``roundingWithSaturation(_:)``.
  @inlinable @inline(__always)
  public func rounding(_ rule: RoundingRule = .toNearestOrEven) -> Self {
    if let r = roundingIfRepresentable(rule) { return r }
    if rule == .requireExact {
      preconditionFailure("Fractional part must be zero.")
    }
    preconditionFailure("Overflow while rounding \(self) with rule \(rule).")
  }
  
  /// Round to an integral value, according to the sepecified `RoundingRule`.
  ///
  /// If rounding would overflow, `nil` is returned.
  ///
  /// > Note:
  ///   See also ``rounding(_:)`` and ``roundingWithSaturation(_:)``
  @inlinable @inline(__always)
  public func roundingIfRepresentable(
    _ rule: RoundingRule = .toNearestOrEven
  ) -> Self? {
    let bits = bitPattern
    let int = Self.integralMask
    let frac = Self.fractionMask
    let unit = Self.unit
    let half = Self.half
    let sign = bits.signbit
    switch rule {
      // These three cases never overflow:
    case .down:
      return Self(bitPattern: bits & int)
    case .towardZero:
      return Self(bitPattern: (bits &+ (frac & sign)) & int)
    case .toOdd:
      return Self(bitPattern: (bits & int) | (bits &+ frac) & unit)
      // These have to handle overflow carefully:
    case .up:
      if case let (rounded, false) = bits.addingReportingOverflow(frac) {
        return Self(bitPattern: rounded & int)
      }
    case .awayFromZero:
      if case let (rounded, false) = bits.addingReportingOverflow(frac & ~sign) {
        return Self(bitPattern: rounded & int)
      }
    case .toNearestOrDown:
      if case let (rounded, false) = bits.addingReportingOverflow(half &- 1) {
        return Self(bitPattern: rounded & int)
      }
    case .toNearestOrUp:
      if case let (rounded, false) = bits.addingReportingOverflow(half) {
        return Self(bitPattern: rounded & int)
      }
    case .toNearestOrZero:
      if case let (rounded, false) = bits.addingReportingOverflow(half &- 1 &- sign) {
        return Self(bitPattern: rounded & int)
      }
    case .toNearestOrAway:
      if case let (rounded, false) = bits.addingReportingOverflow(half &+ sign) {
        return Self(bitPattern: rounded & int)
      }
    case .toNearestOrEven:
      let p = bits >> Self.fractionBits & 1
      if case let (rounded, false) = bits.addingReportingOverflow(half &- 1 &+ p) {
        return Self(bitPattern: rounded & int)
      }
    case .stochastically:
      if case let (rounded, false) = bits.addingReportingOverflow(.random(in: 0...frac)) {
        return Self(bitPattern: rounded & int)
      }
    case .requireExact:
      if (bits & frac == 0) { return Self(bitPattern: bits & int) }
    }
    return nil
  }
  
  /// Round to an integral value, according to the sepecified `RoundingRule`.
  ///
  /// If rounding overflows, the result saturates to the largest or smallest
  /// representable _integral value_. For example:
  /// ```
  /// let bigNumber = MyFixedPointFormat.max               // not an integer
  /// let roundedUp = bigNumber.roundedWithSaturation(.up)
  /// ```
  /// Most other operations that saturate return the largest representable
  /// value (`.max`), but that would result in a non-integral result in this
  /// case. Instead, out-of-range values like the one shown above saturate
  /// to `.max.rounded(.down)`.
  ///
  /// This violates the very reasonable expectation that `a.rounded(.up) >= a`,
  /// but this violation is not as bad as the alternative, which is that
  /// `a.rounded(.up)` isn't an integer at all.
  ///
  /// Use ``roundingIfRepresentable(_:)`` if you have to handle overflow in
  /// a different manner.
  @inlinable
  public func roundingWithSaturation(_ rule: RoundingRule = .toNearestOrEven) -> Self {
    let bits = bitPattern
    let int = Self.integralMask
    let frac = Self.fractionMask
    let unit = Self.unit
    let half = Self.half
    let sign = bits.signbit
    switch rule {
    case .down:
      return Self(bitPattern: bits & int)
    case .towardZero:
      return Self(bitPattern: (bits &+ (frac & sign)) & int)
    case .toOdd:
      return Self(bitPattern: (bits & int) | (bits &+ frac) & unit)
    case .up:
      return Self(bitPattern: bits.addingWithSaturation(frac) & int)
    case .awayFromZero:
      return Self(bitPattern: bits.addingWithSaturation(frac & ~sign) & int)
    case .toNearestOrDown:
      return Self(bitPattern: bits.addingWithSaturation(half &- 1) & int)
    case .toNearestOrUp:
      return Self(bitPattern: bits.addingWithSaturation(half) & int)
    case .toNearestOrZero:
      return Self(bitPattern: bits.addingWithSaturation(half &- 1 &- sign) & int)
    case .toNearestOrAway:
      return Self(bitPattern: bits.addingWithSaturation(half &+ sign) & int)
    case .toNearestOrEven:
      let p = bits >> Self.fractionBits & 1
      return Self(bitPattern: bits.addingWithSaturation(half &- 1 &+ p) & int)
    case .stochastically:
      return Self(bitPattern: bits.addingWithSaturation(.random(in: 0...frac)) & int)
    case .requireExact:
      precondition(bits & frac == 0, "fractional part must be zero")
      return Self(bitPattern: bits & int)
    }
  }
}
