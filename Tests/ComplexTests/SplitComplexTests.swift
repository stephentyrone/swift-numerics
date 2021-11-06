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
  
  func testAppend() {
    var a = SplitComplexArray(repeating: Complex<Float>.i, count: 1)
    a.append(Complex(1,1))
    a.append(Complex(2,2))
    a.append(Complex(3,3))
    a.append(Complex(4,4))
    XCTAssertEqual(a[1], Complex(1,1))
    XCTAssertEqual(a[2], Complex(2,2))
    XCTAssertEqual(a[3], Complex(3,3))
    XCTAssertEqual(a[4], Complex(4,4))
  }
  
  func testInterleaveFloat( ) {
    let a = SplitComplexArray(repeating: Complex<Float>.i, count: 1024)
    measure {
      let _ = Array(a)
    }
  }
  
  func testInterleaveDouble( ) {
    let a = SplitComplexArray(repeating: Complex<Double>.i, count: 1024)
    measure {
      let _ = Array(a)
    }
  }
  
  func testDeinterleaveFloat( ) {
    let a = Array(repeating: Complex<Float>.i, count: 1024)
    measure {
      let _ = SplitComplexArray(a)
    }
  }
  
  func testDeinterleaveDouble( ) {
    let a = Array(repeating: Complex<Double>.i, count: 1024)
    measure {
      let _ = SplitComplexArray(a)
    }
  }
}
