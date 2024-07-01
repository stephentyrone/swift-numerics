//===--- OverflowArithmetic.swift -----------------------------*- swift -*-===//
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
  public func addingReportingOverflow(_ other: Self) -> (
    partialValue: Self,
    overflow: Bool
  ) {
    let r = self.bitPattern.addingReportingOverflow(other.bitPattern)
    return (Self(bitPattern: r.partialValue), r.overflow)
  }
  
  @_transparent
  public func subtractingReportingOverflow(_ other: Self) -> (
    partialValue: Self,
    overflow: Bool
  ) {
    let r = self.bitPattern.subtractingReportingOverflow(other.bitPattern)
    return (Self(bitPattern: r.partialValue), r.overflow)
  }
  
  /*
  @_transparent
  public func multipliedReportingOverflow(
    by other: Self, rounding rule: RoundingRule = .toNearestOrEven
  ) -> (
    partialValue: Self,
    overflow: Bool
  ) {
    let (h,t) = self.bitPattern.multipliedFullWidth(by: other.bitPattern)
    
  }
  */
}
