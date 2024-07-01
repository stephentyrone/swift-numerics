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
  Int8Q3(exactly: Double(a)*Double(b), rounding: .down)
}

func referenceDivision(_ a: Int8Q3, _ b: Int8Q3) -> Int8Q3? {
  Int8Q3(exactly: Double(a)/Double(b), rounding: .towardZero)
}

final class NumericTests: XCTestCase {
  func testMultiplicationInt8Q3() {
    for a in Int8.min ... Int8.max {
      let qa = Int8Q3(bitPattern: a)
      for b in Int8.min ... Int8.max {
        let qb = Int8Q3(bitPattern: b)
        if let qr = referenceMultiplication(qa, qb) {
          XCTAssertEqual(qa*qb, qr)
        }
        if let qq = referenceDivision(qa, qb) {
          XCTAssertEqual(qa/qb, qq)
        }
      }
    }
  }
}
