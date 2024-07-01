//===--- FixedPoint.swift -------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

@frozen
public struct FixedPointMagnitude<F>: FixedPoint where F: FixedPoint {
  
  public typealias Magnitude = Self
  
  public var bitPattern: F.IntegerType.Magnitude
  
  @_transparent public static var fractionBits: Int { F.fractionBits }
  
  @_transparent public init(bitPattern: F.IntegerType.Magnitude) {
    self.bitPattern = bitPattern
  }
  
  @_transparent public var magnitude: Self { self }
}
