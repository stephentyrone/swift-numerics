//===--- SaturatingArithmetic.swift ---------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension FixedWidthInteger {
  /// `~0` (all-ones) if this value is negative, otherwise `0`.
  ///
  /// Note that if `Self` is unsigned, this always returns `0`,
  /// but it is useful for writing algorithms that are generic over
  /// signed and unsigned integers.
  @inline(__always) @usableFromInline
  package var signbit: Self {
    return self < .zero ? ~.zero : .zero
  }
  
  /// The number of "value bits" (i.e. non-sign bits) used to represent
  /// values of the type.
  @_transparent
  public static var valueBits: Int {
    bitWidth &- (isSigned ? 1 : 0)
  }
  
  /// Saturating integer addition
  ///
  /// `self + other` clamped to the representable range of the type. e.g.:
  /// ```
  /// let a: Int8 = 84
  /// let b: Int8 = 100
  /// // 84 + 100 = 184 is not representable as
  /// // Int8, so `c` is clamped to Int8.max (127).
  /// let c = a.addingWithSaturation(b)
  /// ```
  ///
  /// If the "normal addition" `self + other` does not trap,
  /// this method produces the same result.
  @inlinable
  public func addingWithSaturation(_ other: Self) -> Self {
    let (wrapped, overflow) = addingReportingOverflow(other)
    return overflow ? Self.max &- signbit : wrapped
  }
  
  /// Saturating integer subtraction
  ///
  /// `self - other` clamped to the representable range of the type. e.g.:
  /// ```
  /// let a: UInt = 37
  /// let b: UInt = 42
  /// // 37 - 42 = -5, which is not representable as
  /// // UInt, so `c` is clamped to UInt.min (zero).
  /// let c = a.subtractingWithSaturation(b)
  /// ```
  ///
  /// Note that `a.addingWithSaturation(-b)` is not always equivalent to
  /// `a.subtractingWithSaturation(b)`, because `-b` is not representable
  /// if `b` is the minimum value of a signed type.
  ///
  /// If the "normal subtraction" `self - other` does not trap,
  /// this method produces the same result.
  @inlinable
  public func subtractingWithSaturation(_ other: Self) -> Self {
    let (wrapped, overflow) = subtractingReportingOverflow(other)
    if !overflow { return wrapped }
    return Self.isSigned ? Self.max &- signbit : 0
  }
  
  /// Saturating integer negation
  ///
  /// For unsigned types, the result is always zero. This is not very
  /// interesting, but may occasionally be useful in generic contexts.
  /// For signed types, the result is `-self` unless `self` is `.min`,
  /// in which case the result is `.max`.
  @inlinable
  public func negatedWithSaturation() -> Self {
    Self.zero.subtractingWithSaturation(self)
  }
  
  /// Saturating integer multiplication
  ///
  /// `self * other` clamped to the representable range of the type. e.g.:
  /// ```
  /// let a: Int8 = -16
  /// let b: Int8 = -8
  /// // -16 * -8 = 128 is not representable as
  /// // Int8, so `c` is clamped to Int8.max (127).
  /// let c = a.multipliedWithSaturation(by: b)
  /// ```
  ///
  /// If the "normal multiplication" `self * other` does not trap,
  /// this method produces the same result.
  @inlinable
  public func multipliedWithSaturation(by other: Self) -> Self {
    let (high, low) = multipliedFullWidth(by: other)
    let wrapped = Self(truncatingIfNeeded: low)
    if high == wrapped.signbit { return wrapped }
    return Self.max &- high.signbit
  }
}
