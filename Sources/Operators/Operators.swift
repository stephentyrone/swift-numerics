//===--- Operators.swift --------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import Numerics

postfix operator %
infix operator ±: RangeFormationPrecedence
infix operator ≈: ComparisonPrecedence
infix operator ≉: ComparisonPrecedence

public struct Percent<T> where T: FloatingPoint {
  internal var percent: T
  internal var value: T { percent / 100 }
}

public extension FloatingPoint {
  static postfix func %(percent: Self) -> Percent<Self> {
    Percent(percent: percent)
  }
}

public struct ApproximateEqualityRHS<T> where T: Numeric, T.Magnitude: FloatingPoint {
  internal var value: T
  internal var atol: T.Magnitude
  internal var rtol: T.Magnitude
}

public extension Numeric where Magnitude: FloatingPoint {
  static func ±(value: Self, tolerance: Magnitude) -> ApproximateEqualityRHS<Self> {
    ApproximateEqualityRHS(value: value, atol: tolerance, rtol: 0)
  }
  
  static func ±(value: Self, tolerance: Percent<Magnitude>) -> ApproximateEqualityRHS<Self> {
    let rtol = tolerance.value
    let atol = rtol * .leastNormalMagnitude
    return ApproximateEqualityRHS(value: value, atol: atol, rtol: rtol)
  }
  
  static func ≈(lhs: Self, rhs: Self) -> Bool {
    lhs.isApproximatelyEqual(to: rhs)
  }
  
  static func ≉(lhs: Self, rhs: Self) -> Bool {
    !lhs.isApproximatelyEqual(to: rhs)
  }
  
  static func ≈(lhs: Self, rhs: ApproximateEqualityRHS<Self>) -> Bool {
    lhs.isApproximatelyEqual(
      to: rhs.value,
      absoluteTolerance: rhs.atol,
      relativeTolerance: rhs.rtol
    )
  }
  
  static func ≉(lhs: Self, rhs: ApproximateEqualityRHS<Self>) -> Bool {
    !lhs.isApproximatelyEqual(
      to: rhs.value,
      absoluteTolerance: rhs.atol,
      relativeTolerance: rhs.rtol
    )
  }
}
