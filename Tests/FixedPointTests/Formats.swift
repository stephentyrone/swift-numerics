//===--- Formats.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import FixedPointModule

internal struct Int8Q3: FixedPoint {
  public var bitPattern: Int8
  @_transparent public static var fractionBits: Int { 3 }
  @_transparent public init(bitPattern: Int8) {
    self.bitPattern = bitPattern
  }
}

internal struct Int8Q7: FixedPoint {
  public var bitPattern: Int8
  @_transparent public static var fractionBits: Int { 7 }
  @_transparent public init(bitPattern: Int8) {
    self.bitPattern = bitPattern
  }
}

internal struct UIntQ8: FixedPoint {
  public var bitPattern: UInt8
  @_transparent public static var fractionBits: Int { 8 }
  @_transparent public init(bitPattern: UInt8) {
    self.bitPattern = bitPattern
  }
}

internal struct UInt8Q7: FixedPoint {
  public var bitPattern: UInt8
  @_transparent public static var fractionBits: Int { 7 }
  @_transparent public init(bitPattern: UInt8) {
    self.bitPattern = bitPattern
  }
}

internal struct Int32Q6: FixedPoint {
  public var bitPattern: Int32
  @_transparent public static var fractionBits: Int { 6 }
  @_transparent public init(bitPattern: Int32) {
    self.bitPattern = bitPattern
  }
}
