//===--- Rotate.swift -----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2021 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// MARK: - Rotate
extension FixedWidthInteger where Self: UnsignedInteger {
  /// The number formed by "rotating" the bit pattern of self right by count bits.
  ///
  /// Rotation is just like a shift, but instead of discarding bits as they shift off
  /// of the number, those bits re-appear on the opposite side. Some examples
  /// will explain better than text can:
  ///
  /// ```swift
  /// let a: UInt8 = 0b1111_0010
  /// a.rotated(right: 0) // 0b1111_0010
  /// a.rotated(right: 1) // 0b0111_1001
  /// a.rotated(right: 2) // 0b1011_1100
  /// a.rotated(right: 3) // 0b0101_1110
  /// a.rotated(right: 4) // 0b0010_1111
  /// a.rotated(right: 5) // 0b1001_0111
  /// a.rotated(right: 6) // 0b1100_1011
  /// a.rotated(right: 7) // 0b1110_0101
  /// a.rotated(right: 8) // 0b1111_0010
  /// ```
  ///
  /// If `count` is negative, the bit pattern is rotated left by `-count` bits.
  @_transparent
  public func rotated<T: BinaryInteger>(right count: T) -> Self {
    let right = Int(truncatingIfNeeded: count) & (Self.bitWidth - 1)
    let left = Self.bitWidth - right
    return self &>> right | self &<< left
  }
  
  /// The number formed by "rotating" the bit pattern of self left by count bits.
  ///
  /// If `count` is negative, the bit pattern is rotated right by `-count` bits.
  @_transparent
  public func rotated<T: BinaryInteger>(left count: T) -> Self {
    rotated(right: 0 &- Int(truncatingIfNeeded: count))
  }
}
