//===--- FloatingPoint.swift ----------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

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
