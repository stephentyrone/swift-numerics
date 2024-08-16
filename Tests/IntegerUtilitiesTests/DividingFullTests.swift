//===--- DividingFullTests.swift ------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import IntegerUtilities
import XCTest

final class IntegerUtilitiesDividingFullTests: XCTestCase {
  
  func checkUInt8(_ ahi: UInt8, _ alo: UInt8, _ b: UInt8, _ rule: RoundingRule) {
    let ref = (UInt16(ahi) << 8 | UInt16(alo)).divided(by: UInt16(b), rounding: rule)
    if let obs = b.dividing((ahi, alo), rounding: rule) {
      if obs != ref {
        XCTFail("""
Error in \(b).dividing((\(ahi), \(alo)), rounding: \(rule))
Expected \(ref)
Observed \(obs)
""")
      }
    } else {
      if ref <= UInt8.max {
        XCTFail("""
Error in \(b).dividing((\(ahi), \(alo)), rounding: \(rule))
Expected \(ref)
Observed nil
""")
      }
    }
  }
  
  func testUInt8Divide() {
    for b in 1 ... UInt8.max {
#if DEBUG
      let loVals = [UInt8.zero, b, .max]
#else
      let loVals = 0 ... UInt8.max
#endif
      for ahi in 0 ... UInt8.max {
        for alo in loVals {
          checkUInt8(ahi, alo, b, .down)
          checkUInt8(ahi, alo, b, .up)
          checkUInt8(ahi, alo, b, .towardZero)
          checkUInt8(ahi, alo, b, .awayFromZero)
          checkUInt8(ahi, alo, b, .toNearestOrDown)
          checkUInt8(ahi, alo, b, .toNearestOrUp)
          checkUInt8(ahi, alo, b, .toNearestOrZero)
          checkUInt8(ahi, alo, b, .toNearestOrAway)
          checkUInt8(ahi, alo, b, .toNearestOrEven)
          checkUInt8(ahi, alo, b, .toOdd)
        }
      }
    }
  }
  
  func checkInt8(_ ahi: Int8, _ alo: UInt8, _ b: Int8, _ rule: RoundingRule) {
    let a = Int16(ahi) << 8 | Int16(alo)
    let ref: Int16
    if (a == .min && b == -1) { ref = .max }
    else { ref = a.divided(by: Int16(b), rounding: rule) }
    if let obs = b.dividing((ahi, alo), rounding: rule) {
      if obs != ref {
        XCTFail("""
Error in \(b).dividing((\(ahi), \(alo)), rounding: \(rule))
Expected \(ref)
Observed \(obs)
""")
      }
    } else {
      if let ref = Int8(exactly: ref) {
        XCTFail("""
Error in \(b).dividing((\(ahi), \(alo)), rounding: \(rule))
Expected \(ref)
Observed nil
""")
      }
    }
  }
  
  func testInt8Divide() {
    for b in Int8.min ... Int8.max {
      if b == 0 { continue }
#if DEBUG
      let loVals = [UInt8.zero, UInt8(truncatingIfNeeded: b), .max]
#else
      let loVals = 0 ... UInt8.max
#endif
      for ahi in Int8.min ... Int8.max {
        for alo in loVals {
          checkInt8(ahi, alo, b, .down)
          checkInt8(ahi, alo, b, .up)
          checkInt8(ahi, alo, b, .towardZero)
          checkInt8(ahi, alo, b, .awayFromZero)
          checkInt8(ahi, alo, b, .toNearestOrDown)
          checkInt8(ahi, alo, b, .toNearestOrUp)
          checkInt8(ahi, alo, b, .toNearestOrZero)
          checkInt8(ahi, alo, b, .toNearestOrAway)
          checkInt8(ahi, alo, b, .toNearestOrEven)
          checkInt8(ahi, alo, b, .toOdd)
        }
      }
    }
  }
}
