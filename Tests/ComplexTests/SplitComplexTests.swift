//===--- SplitComplexTests.swift ------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import ComplexModule
import RealModule

final class SplitComplexTests: XCTestCase {
  func testRepeatingInit<T: Real>(_ type: T.Type) {
    var a = SplitComplexArray(repeating: Complex<T>.i, count: 8)
    for i in a.indices {
      a[i] *= Complex(i)
    }
    print(a)
  }
  
  func testRepeatingInit() {
    testRepeatingInit(Float.self)
  }
  
  func testInterleaveFloat( ) {
    let a = SplitComplexArray(repeating: Complex<Float>.i, count: 1024)
    measure {
      let _ = a.interleave()
    }
  }
}
