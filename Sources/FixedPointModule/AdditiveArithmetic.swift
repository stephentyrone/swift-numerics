//===--- AdditiveArithmetic.swift -----------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension FixedPoint {
  @_transparent
  public static var zero: Self {
    Self(bitPattern: .zero)
  }
  
  @_transparent
  public static func +(a: Self, b: Self) -> Self {
    Self(bitPattern: a.bitPattern + b.bitPattern)
  }
  
  @_transparent
  public static func -(a: Self, b: Self) -> Self {
    Self(bitPattern: a.bitPattern - b.bitPattern)
  }
}

extension FixedPoint {
  @_transparent
  public static func &+(a: Self, b: Self) -> Self {
    Self(bitPattern: a.bitPattern &+ b.bitPattern)
  }
  
  @_transparent
  public static func &-(a: Self, b: Self) -> Self {
    Self(bitPattern: a.bitPattern &- b.bitPattern)
  }
  
  @_transparent
  public static func &+=(a: inout Self, b: Self) {
    a.bitPattern &+= b.bitPattern
  }
  
  @_transparent
  public static func &-=(a: inout Self, b: Self) {
    a.bitPattern &-= b.bitPattern
  }
}
