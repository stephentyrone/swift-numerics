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

import FixedPointModule
import XCTest

final class AdditiveArithmeticTests: XCTestCase {
  func testAdditionInt8Q3() {
    for a in Int8.min ... Int8.max {
      let qa = Int8Q3(bitPattern: a)
      for b in Int8.min ... Int8.max {
        let qb = Int8Q3(bitPattern: b)
        let (r,o) = a.addingReportingOverflow(b)
        let qr = Int8Q3(bitPattern: r)
        if !o {
          XCTAssertEqual(qr, qa + qb)
          XCTAssertEqual(qr, qa.addingWithSaturation(qb))
        } else {
          XCTAssertEqual(qa > 0 ? .max : .min, qa.addingWithSaturation(qb))
        }
        XCTAssertEqual(qr, qa &+ qb)
        XCTAssertEqual(qr, qa.addingReportingOverflow(qb).partialValue)
        XCTAssertEqual(o, qa.addingReportingOverflow(qb).overflow)
      }
    }
  }
  
  func testSubtractionInt8Q3() {
    for a in Int8.min ... Int8.max {
      let qa = Int8Q3(bitPattern: a)
      for b in Int8.min ... Int8.max {
        let qb = Int8Q3(bitPattern: b)
        let (r,o) = a.subtractingReportingOverflow(b)
        let qs = qa.subtractingWithSaturation(qb)
        let qr = Int8Q3(bitPattern: r)
        if !o {
          XCTAssertEqual(qr, qa - qb)
          XCTAssertEqual(qr, qs)
        } else {
          XCTAssertEqual(qa >= 0 ? .max : .min, qs)
        }
        XCTAssertEqual(qr, qa &- qb)
        XCTAssertEqual(qr, qa.subtractingReportingOverflow(qb).partialValue)
        XCTAssertEqual(o, qa.subtractingReportingOverflow(qb).overflow)
      }
    }
  }
  
  func testNegationInt8Q3() {
    for a in -Int8.max ... Int8.max {
      let qa = Int8Q3(bitPattern: a)
      XCTAssertEqual(Int8Q3(bitPattern: -a), -qa)
      XCTAssertEqual(Int8Q3(bitPattern: abs(a)), abs(qa))
    }
  }
}
