//===--- Magnitude.swift --------------------------------------*- swift -*-===//
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

/// The Magnitude of a signed FixedPoint type.
///
/// This is an unsigned FixedPoint type whose IntegerType is the magnitude
/// of Wrapped.IntegerType, and which has the same number of fractionalBits
/// as Wrapped.
@frozen
public struct FixedPointMagnitude<Wrapped>: FixedPoint where Wrapped: FixedPoint {
  
  public typealias Magnitude = Self
  
  public var bitPattern: Wrapped.IntegerType.Magnitude
  
  @_transparent public static var fractionBits: Int {
    Wrapped.fractionBits
  }
  
  @_transparent public static var defaultRounding: RoundingRule {
    Wrapped.defaultRounding
  }
  
  @_transparent public init(bitPattern: Wrapped.IntegerType.Magnitude) {
    self.bitPattern = bitPattern
  }
  
  @_transparent public var magnitude: Self { self }
}
