//===--- MultiplyShift.swift ----------------------------------*- swift -*-===//
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
  
  @inlinable @inline(__always)
  public func multiplied<R>(
    by other: Self,
    shiftingRightBy count: Int,
    rounding rule: RoundingRule = .down,
    to type: R.Type = Self.self
  ) -> R? where R: FixedWidthInteger {
    
    if count <= 0 {
      // No rounding takes place because the shift is just multiplying as well.
      let product = self.multipliedFullWidth(by: other)
      guard let productR = R(exactly: product) else { return nil }
      guard case let (result, false) = productR.shiftedReportingOverflow(
        leftBy: -count
      ) else {
        return nil
      }
      return result
    }
    
    else if count <= Self.bitWidth {
      let unit: Magnitude = 1 << count // zero if count == bitWidth
      let frac: Magnitude = unit &- 1
      let half: Magnitude = 1 &<< (count &- 1)
      
      var product = self.multipliedFullWidth(by: other)
      let sign = Magnitude(truncatingIfNeeded: product.high.signbit)
      
      func add(roundingTerm addend: Magnitude) {
        let (low, carry) = product.low.addingReportingOverflow(addend)
        let high = product.high &+ (carry ? 1 : 0)
        product = (high, low)
      }
      
      switch rule {
      case .down:            add(roundingTerm: 0)
      case .up:              add(roundingTerm: frac)
      case .towardZero:      add(roundingTerm: frac &  sign)
      case .awayFromZero:    add(roundingTerm: frac & ~sign)
      case .toNearestOrDown: add(roundingTerm: half &- 1)
      case .toNearestOrUp:   add(roundingTerm: half)
      case .toNearestOrZero: add(roundingTerm: half &+ ~sign)
      case .toNearestOrAway: add(roundingTerm: half &+  sign)
      case .toNearestOrEven:
        let parity: Magnitude
        if count == Self.bitWidth {
          parity = Magnitude(truncatingIfNeeded: product.high) & 1
        } else {
          parity = product.low >> count & 1
        }
        add(roundingTerm: half &- 1 &+ parity)
      case .toOdd:
        if count == Self.bitWidth {
          product.high |= product.low == 0 ? 1 : 0
        } else {
          product.low |= (product.low &+ frac) & unit
        }
      case .requireExact:
        guard product.low & frac == 0 else {
          preconditionFailure("Multiplication is not exact.")
        }
      }
      
      if R.bitWidth >= 2*Self.bitWidth {
        
      }
      
      /*
      let lostBits = product.high >> (count - (Self.isSigned ? 1 : 0))
      guard lostBits == product.high.signbit else { return nil }
      
      let bitsFromLo = R(truncatingIfNeeded: product.low >> count)
      let bitsFromHi = product.high &<< (Self.bitWidth &- count)
      return R(truncatingIfNeeded: bitsFromHi | bitsFromLo)
      */
    }
    
    else {
      fatalError()
    }
    fatalError()
  }
}
