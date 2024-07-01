//===--- Integers.swift ---------------------------------------*- swift -*-===//
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

// MARK: ExpressibleByIntegerLiteral
extension FixedPoint {
  @inlinable
  public init(integerLiteral value: IntegerType.IntegerLiteralType) {
    Self.invariantCheck()
    let unscaledInteger = IntegerType(integerLiteral: value)
    // If unit is zero, there are only fraction bits, and therefore the
    // only representable integral value is zero.
    precondition(Self.unit != 0 || unscaledInteger == 0, "\(value) cannot be represented in \(Self.name).")
    self = Self(bitPattern: unscaledInteger * Self.unit)
  }
}

// MARK: - Inits from BinaryInteger
extension FixedPoint {
  @inlinable
  public init?<Other: BinaryInteger>(exactly other: Other) {
    Self.invariantCheck()
    guard let unscaledInteger = IntegerType(exactly: other) else {
      return nil
    }
    guard Self.unit != 0 || unscaledInteger == 0 else { return nil }
    self = Self(bitPattern: unscaledInteger * Self.unit)
  }
  
  @inlinable
  public init<Other: BinaryInteger>(_ other: Other) {
    Self.invariantCheck()
    // This might trap, but if it does, we would have trapped anyway.
    let unscaledInteger = IntegerType(other)
    // If unit is zero, there are only fraction bits, and therefore the
    // only representable integral value is zero.
    precondition(
      Self.unit != 0 || unscaledInteger == 0,
      "\(other) cannot be represented in \(Self.name)."
    )
    self = Self(bitPattern: unscaledInteger * Self.unit)
  }
}
