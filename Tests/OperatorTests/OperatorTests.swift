//===--- OperatorTests.swift ----------------------------------*- swift -*-===//
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
import Operators
import XCTest

final class ElementaryFunctionTests: XCTestCase {
  func testApproximateComparisonOperators() {
    XCTAssert(1.2 ≈ 1 ± 0.2)
    XCTAssert(Complex(1,1) ≈ Complex(0.9, 0.9) ± 10%)
    XCTAssert(Complex(1,0) ≉ Complex(0,1))
  }
}
