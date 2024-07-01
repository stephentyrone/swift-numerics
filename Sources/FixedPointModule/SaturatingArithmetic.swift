//===--- SaturatingArithmetic.swift ---------------------------*- swift -*-===//
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
  @_transparent
  public func addingWithSaturation(_ other: Self) -> Self {
    Self(bitPattern: self.bitPattern.addingWithSaturation(other.bitPattern))
  }
  
  @_transparent
  public func subtractingWithSaturation(_ other: Self) -> Self {
    Self(bitPattern: self.bitPattern.subtractingWithSaturation(other.bitPattern))
  }
  
  @_transparent
  public func negatedWithSaturation() -> Self {
    Self(bitPattern: self.bitPattern.negatedWithSaturation())
  }
}
