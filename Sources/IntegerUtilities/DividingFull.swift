//===--- DividingFull.swift -----------------------------------*- swift -*-===//
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
  
  @usableFromInline @_transparent
  var nextUp: Self? {
    guard case let (result, false) = addingReportingOverflow(1) else {
      return nil
    }
    return result
  }
  
  /// The quotient produced dividing the specified `dividend` by this value,
  /// rounding according to the specified `rule`, if it is representable.
  ///
  /// If the result is not representable, because one of the following criteria
  /// hold:
  /// - the divisor is zero
  /// - the quotient would overflow
  /// - the quotient is not exact and the rounding rule is `.requireExact`
  /// then the result is `nil`.
  @inlinable
  public func dividing(
    _ dividend: (high: Self, low: Magnitude),
    rounding rule: RoundingRule
  ) -> Self? {
    if Self.isSigned {
      // Convert to unsigned, and adjust rounding rule to match; we can
      // determine the sign of the quotient from signs of dividend and
      // divisor and swap up/down to achieve the correct direction.
      let unsignedDividend: (high: Magnitude, low: Magnitude)
      if dividend.high < 0 {
        let (low, carry) = (~dividend.low).addingReportingOverflow(1)
        let high = Magnitude(truncatingIfNeeded: ~dividend.high) &+ (carry ? 1 : 0)
        unsignedDividend = (high, low)
      } else {
        unsignedDividend = (Magnitude(truncatingIfNeeded: dividend.high), dividend.low)
      }
      let resultIsNegative = dividend.high ^ self < 0
      let unsignedRule = resultIsNegative ? rule.negated : rule
      // Do the division in unsigned; if it overflows, then signed division
      // would too.
      guard let quotient = magnitude.dividing(unsignedDividend, rounding: unsignedRule) else {
        return nil
      }
      // Apply the correct sign to the quotient, returning nil if this
      // overflows.
      if resultIsNegative {
        guard quotient <= Magnitude(truncatingIfNeeded: Self.min) else { return nil }
        return Self(truncatingIfNeeded: 0 &- quotient)
      } else {
        return Self(exactly: quotient)
      }
    } else {
      let addend: Magnitude
      switch rule {
      // It's generally somewhat neater to handle rounding by adding a term
      // before doing the division; the following rounding modes can be
      // handled that way:
      case .down, .towardZero:
        addend = 0
        
      case .up, .awayFromZero:
        addend = magnitude &- 1
        
      case .toNearestOrDown, .toNearestOrZero:
        addend = (magnitude &- 1) &>> 1
        
      case .toNearestOrUp, .toNearestOrAway:
        addend = magnitude &>> 1
        
      case .stochastically:
        addend = .random(in: 0 ..< magnitude)
      
      // These modes cannot easily be handled by just adjusting the dividend,
      // so we implement them completely here instead of using the shared
      // body that follows the switch.
      case .toOdd:
        guard dividend.high < self else { return nil }
        let (q, r) = dividingFullWidth(dividend)
        return q | (r == 0 ? 0 : 1)
        
      case .toNearestOrEven:
        guard dividend.high < self else { return nil }
        let (q, r) = dividingFullWidth(dividend)
        let half = (magnitude - (q.magnitude & 1)) &>> 1
        return r > half ? q.nextUp : q
        
      case .requireExact:
        guard dividend.high < self else { return nil }
        let (q, r) = dividingFullWidth(dividend)
        return r == 0 ? q : nil
      }
      
      let adjusted: (high: Self, low: Magnitude)
      var carry: Bool = false
      (adjusted.low, carry) = dividend.low.addingReportingOverflow(addend)
      (adjusted.high, carry) = dividend.high.addingReportingOverflow(carry ? 1 : 0)
      guard !carry && adjusted.high < self else { return nil }
      return dividingFullWidth(adjusted).quotient
    }
  }
}
