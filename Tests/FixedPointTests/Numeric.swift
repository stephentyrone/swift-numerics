//===--- Numeric.swift ----------------------------------------*- swift -*-===//
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
import IntegerUtilities
import XCTest

func referenceMultiplication(_ a: Int8Q3, _ b: Int8Q3, rounding rule: RoundingRule) -> (Int8Q3, Bool) {
  let ref = (Double(a)*Double(b)*8).rounding(rule)/8
  if let result = Int8Q3(exactly: ref) {
    return (result, false)
  } else {
    let mod = ref.remainder(dividingBy: 32)
    return (mod == 16 ? -16 : Int8Q3(mod), true)
  }
}

func referenceMultiplication(_ a: UIntQ8, _ b: UIntQ8, rounding rule: RoundingRule) -> (UIntQ8, Bool) {
  let ref = (Double(a)*Double(b)*256).rounding(rule)/256
  if let result = UIntQ8(exactly: ref) {
    return (result, false)
  } else {
    let mod = ref.truncatingRemainder(dividingBy: 1)
    return (UIntQ8(mod), true)
  }
}

func referenceMultiplication(_ a: UInt8Q7, _ b: UInt8Q7, rounding rule: RoundingRule) -> (UInt8Q7, Bool) {
  let ref = (Double(a)*Double(b)*128).rounding(rule)/128
  if let result = UInt8Q7(exactly: ref) {
    return (result, false)
  } else {
    let mod = ref.truncatingRemainder(dividingBy: 2)
    return (UInt8Q7(mod), true)
  }
}

final class NumericTests: XCTestCase {
  func testMultiplicationInt8Q3() {
    for a in Int8.min ... Int8.max {
      let qa = Int8Q3(bitPattern: a)
      XCTAssertEqual(qa.magnitude.bitPattern, a.magnitude)
      for b in Int8.min ... Int8.max {
        let qb = Int8Q3(bitPattern: b)
        if case let (qr, false) = referenceMultiplication(qa, qb, rounding: .toNearestOrUp) {
          let qp = qa*qb
          if qp != qr {
            XCTFail("\(qa)*\(qb) was \(qp), expected \(qr); real value: (\(Double(qa)*Double(qb)))")
          }
        }
      }
    }
  }
  
  func testMultiplicationInt8Q3WithRounding() {
    for rule in [
      RoundingRule.down, .up, .towardZero, .awayFromZero,
      .toNearestOrDown, .toNearestOrUp, .toNearestOrZero, .toNearestOrAway,
      .toNearestOrEven, .toOdd
    ] {
      for a in Int8.min ... Int8.max {
        let qa = Int8Q3(bitPattern: a)
        XCTAssertEqual(qa.magnitude.bitPattern, a.magnitude)
        for b in Int8.min ... Int8.max {
          let qb = Int8Q3(bitPattern: b)
          let qr = referenceMultiplication(qa, qb, rounding: rule)
          let qp = qa.multipliedReportingOverflow(by: qb, rounding: rule)
          if qp != qr {
            XCTFail("\(qa).multiplied(by: \(qb), rounding: \(rule)) was \(qp), expected \(qr); real value: (\(Double(qa)*Double(qb)))")
          }
          if qr.1 == true {
            XCTAssertEqual(
              qa.multipliedWithSaturation(by: qb, rounding: rule),
              (qa < 0) == (qb < 0) ? .max : .min
            )
          } else {
            XCTAssertEqual(
              qa.multipliedWithSaturation(by: qb, rounding: rule),
              qr.0
            )
          }
        }
      }
    }
  }
  
  func testMultiplicationUIntQ8WithRounding() {
    for rule in [
      RoundingRule.down, .up, .towardZero, .awayFromZero,
      .toNearestOrDown, .toNearestOrUp, .toNearestOrZero, .toNearestOrAway,
      .toNearestOrEven, .toOdd
    ] {
      for a in 0 ... UInt8.max {
        let qa = UIntQ8(bitPattern: a)
        XCTAssertEqual(qa.magnitude.bitPattern, a.magnitude)
        for b in 0 ... UInt8.max {
          let qb = UIntQ8(bitPattern: b)
          let qr = referenceMultiplication(qa, qb, rounding: rule)
          let qp = qa.multipliedReportingOverflow(by: qb, rounding: rule)
          if qp != qr {
            XCTFail("\(qa).multiplied(by: \(qb), rounding: \(rule)) was \(qp), expected \(qr); real value: (\(Double(qa)*Double(qb)))")
          }
          if qr.1 == true {
            XCTAssertEqual(
              qa.multipliedWithSaturation(by: qb, rounding: rule),
              (qa < 0) == (qb < 0) ? .max : .min
            )
          } else {
            XCTAssertEqual(
              qa.multipliedWithSaturation(by: qb, rounding: rule),
              qr.0
            )
          }
        }
      }
    }
  }
  
  func testMultiplicationUInt8Q7WithRounding() {
    for rule in [
      RoundingRule.down, .up, .towardZero, .awayFromZero,
      .toNearestOrDown, .toNearestOrUp, .toNearestOrZero, .toNearestOrAway,
      .toNearestOrEven, .toOdd
    ] {
      for a in 0 ... UInt8.max {
        let qa = UInt8Q7(bitPattern: a)
        XCTAssertEqual(qa.magnitude.bitPattern, a.magnitude)
        for b in 0 ... UInt8.max {
          let qb = UInt8Q7(bitPattern: b)
          let qr = referenceMultiplication(qa, qb, rounding: rule)
          let qp = qa.multipliedReportingOverflow(by: qb, rounding: rule)
          if qp != qr {
            XCTFail("\(qa).multiplied(by: \(qb), rounding: \(rule)) was \(qp), expected \(qr); real value: (\(Double(qa)*Double(qb)))")
          }
          if qr.1 == true {
            XCTAssertEqual(
              qa.multipliedWithSaturation(by: qb, rounding: rule),
              (qa < 0) == (qb < 0) ? .max : .min
            )
          } else {
            XCTAssertEqual(
              qa.multipliedWithSaturation(by: qb, rounding: rule),
              qr.0
            )
          }
        }
      }
    }
  }
}
