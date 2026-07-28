//===--- Power.swift ------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension FixedWidthInteger {
  /// Returns the (wrapped) product of `self` and `other`, and updates a
  /// cummulative overflow `flag`.
  ///
  /// This is just sugar that makes the implementation of
  /// `powerReportingOverflow` a little bit tidier.
  private func multiplied(by other: Self, updatingOverflow flag: inout Bool) -> Self {
    let (result, overflow) = self.multipliedReportingOverflow(by: other)
    if overflow { flag = true }
    return result
  }
  
  /// Returns `self` raised to the `k`th power computed with wrapping
  /// arithmetic, as well as a boolean flag indicating whether or not
  /// the computation overflowed.
  public func powerReportingOverflow(_ k: Int) -> (partialValue: Self, overflow: Bool) {
    precondition(k >= 0, "Exponent must be non-negative, but was \(k).")
    let bits = Int.bitWidth - k.leadingZeroBitCount
    var result: Self = 1
    var next: Self = self
    var overflow = false
    for i in 0 ..< bits {
      if k &>> i & 1 == 1 {
        result = result.multiplied(by: next, updatingOverflow: &overflow)
      }
      if i != bits-1 {
        next = next.multiplied(by: next, updatingOverflow: &overflow)
      }
    }
    return (result, overflow)
  }
  
  /// The square root of `self`, rounded down to an integer.
  ///
  /// This cannot overflow, because the square root always has smaller
  /// magnitude than the original integer.
  public func squareRoot() -> Self {
    precondition(self >= 0)
    if self == 0 { return 0 }
    let bits = Self.bitWidth - self.leadingZeroBitCount
    // Get an over-estimate.
    var root = Self(1) &<< (bits/2 + 1)
    // Iterative refinement via Newton's method.
    while true {
      let update = self/root
      if update >= root { break }
      // Don't need to be fancy about this average; it cannot overflow
      // because r and q are both at most about half the width of the
      // type.
      root = (root &+ update)/2
    }
    return root
  }
  
  /// The `k`th root of `self`, rounded down to an integer.
  ///
  /// This cannot overflow, because the root always has smaller
  /// magnitude than the original integer (or equal magnitude if `k == 1`).
  ///
  /// - Precondition: `k` must be positive.
  /// - Precondition: If `self` is negative, `k` must be odd.
  public func root(_ k: Int) -> Self {
    // We have a few new preconditions vis-a-vis squareRoot, since we have
    // to handle variable k:
    precondition(k > 0, "k must be positive, but was \(k).")
    if k == 1 { return self }
    if self == 0 { return 0 }
    // If k is odd, we need to support negative values as well; that doesn't
    // happen for square roots. Take the root of the magnitude and fix up
    // its sign afterwards. This is always safe because the magnitude of a
    // root is less than or equal to the magnitude of self.
    if self < 0 {
      precondition(k & 1 == 1,
        "Cannot take even root of a negative value (\(self).root(\(k)))."
      )
      return 0 &- Self(magnitude.root(k))
    }
    // From here on it's the same as square root. Get an over-estimate, do
    // Newton steps to convergance.
    let bits = Self.bitWidth - self.leadingZeroBitCount
    // If k is bigger than bitWidth, the result is unconditionally 1.
    if k > bits { return 1 }
    var root = Self(1) &<< (bits/k + 1)
    while true {
      let (divisor, overflow) = root.powerReportingOverflow(k-1)
      let update = overflow ? 0 : self/divisor
      if update >= root { break }
      // This weighted average cannot overflow for the same reasons that the
      // average in squareRoot is safe.
      root = (Self(k-1)*root + update)/Self(k)
    }
    return root
  }
}
