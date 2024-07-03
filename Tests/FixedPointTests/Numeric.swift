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
import XCTest

func referenceMultiplication(_ a: Int8Q3, _ b: Int8Q3) -> Int8Q3? {
  Int8Q3(exactly: Double(a)*Double(b), rounding: .toNearestOrUp)
}

func referenceDivision(_ a: Int8Q3, _ b: Int8Q3) -> Int8Q3? {
  Int8Q3(exactly: Double(a)/Double(b), rounding: .towardZero)
}

final class NumericTests: XCTestCase {
  func testMultiplicationInt8Q3() {
    for a in Int8.min ... Int8.max {
      let qa = Int8Q3(bitPattern: a)
      XCTAssertEqual(qa.magnitude.bitPattern, a.magnitude)
      for b in Int8.min ... Int8.max {
        let qb = Int8Q3(bitPattern: b)
        if let qr = referenceMultiplication(qa, qb) {
          let qp = qa*qb
          if qp != qr {
            XCTFail("\(qa)*\(qb) was \(qp), expected \(qr) (\(Double(qa)*Double(qb)))")
          }
        }
        if let qq = referenceDivision(qa, qb) {
          XCTAssertEqual(qa/qb, qq)
        }
      }
    }
  }
}
