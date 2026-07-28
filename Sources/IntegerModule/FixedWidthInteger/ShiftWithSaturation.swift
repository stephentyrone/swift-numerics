//===--- FixedWidthIntegerShifts.swift ------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021-2026 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension FixedWidthInteger {
  /// Bitwise left shift with rounding, reporting overflow.
  ///
  /// `self` multiplied by the rational number 2^(`count`), saturated to the
  /// range `Self.min ... Self.max`, and rounded according to `rule`.
  ///
  /// See `shifted(rightBy:rounding:)` for more discussion of rounding
  /// shifts with examples.
  ///
  /// - Parameters:
  ///   - count: the number of bits to shift by. If positive, this is a
  ///     left-shift, and if negative a right shift.
  ///   - rule: the direction in which to round if `count` is negative.
  @_transparent
  public func shiftedReportingOverflow<Count: BinaryInteger>(
    leftBy count: Count,
    rounding rule: RoundingRule = .down
  ) -> Self {
    self.shiftedWithSaturation(leftBy: Int(clamping: count), rounding: rule)
  }
  
  /// Bitwise left shift with rounding and saturation.
  ///
  /// `self` multiplied by the rational number 2^(`count`), saturated to the
  /// range `Self.min ... Self.max`, and rounded according to `rule`.
  ///
  /// See `shifted(rightBy:rounding:)` for more discussion of rounding
  /// shifts with examples.
  ///
  /// - Parameters:
  ///   - count: the number of bits to shift by. If positive, this is a
  ///     left-shift, and if negative a right shift.
  ///   - rule: the direction in which to round if `count` is negative.
  @_transparent
  public func shiftedWithSaturation<Count: BinaryInteger>(
    leftBy count: Count,
    rounding rule: RoundingRule = .down
  ) -> Self {
    self.shiftedWithSaturation(leftBy: Int(clamping: count), rounding: rule)
  }
  
  @inlinable @inline(__always)
  internal func shiftedReportingOverflow(
    leftBy count: Int,
    rounding rule: RoundingRule = .down
  ) -> (partialValue: Self, overflow: Bool) {
    // If count is negative, this is just a shift with rounding; no overflow
    // can happen.
    guard count >= 0 else {
      return (self.shifted(
        rightBy: count.negatedWithSaturation(),
        rounding: rule
      ), false)
    }
    // If count is greater than bitWidth, we always overflow, unless the
    // starting value is zero.
    guard count < Self.bitWidth else { return (0, self != 0) }
    // 0 < count < bitWidth. Shift and shift back; if we get the value we
    // started with, there's no overflow.
    let partialValue = self &<< count
    return (partialValue, partialValue &>> count != self)
  }
  
  @inlinable
  internal func shiftedWithSaturation(
    leftBy count: Int,
    rounding rule: RoundingRule = .down
  ) -> Self {
    if case let (result, false) = shiftedReportingOverflow(leftBy: count, rounding: rule) {
      return result
    }
    return Self.max &- signbit
  }
}
