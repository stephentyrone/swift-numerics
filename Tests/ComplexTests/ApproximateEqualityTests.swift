//===--- ApproximateEqualityTests.swift -----------------------*- swift -*-===//
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
  
  func testSpecials<T: Real>(absolute tol: T) {
    let zero = Complex<T>.zero
    let inf = Complex<T>.infinity
    XCTAssert( zero ≈  zero ± tol)
    XCTAssert(-zero ≈  zero ± tol)
    XCTAssert( zero ≈ -zero ± tol)
    XCTAssert(-zero ≈ -zero ± tol)
    // Complex has a single point at infinity.
    XCTAssert( inf ≈  inf ± tol)
    XCTAssert(-inf ≈  inf ± tol)
    XCTAssert(-inf ≈ -inf ± tol)
    XCTAssert(-inf ≈ -inf ± tol)
  }
  
  func testSpecials<T: Real>(relative tol: T) {
    let zero = Complex<T>.zero
    let inf = Complex<T>.infinity
    XCTAssert( zero ≈  zero ± tol%)
    XCTAssert(-zero ≈  zero ± tol%)
    XCTAssert( zero ≈ -zero ± tol%)
    XCTAssert(-zero ≈ -zero ± tol%)
    // Complex has a single point at infinity.
    XCTAssert( inf ≈  inf ± tol%)
    XCTAssert(-inf ≈  inf ± tol%)
    XCTAssert(-inf ≈ -inf ± tol%)
    XCTAssert(-inf ≈ -inf ± tol%)
  }
  
  func testSpecials<T: Real>(_ type: T.Type) {
    XCTAssert(Complex<T>.zero ≈  Complex<T>.zero)
    XCTAssert(Complex<T>.zero ≈ -Complex<T>.zero)
    testSpecials(absolute: T.zero)
    testSpecials(absolute: T.greatestFiniteMagnitude)
    testSpecials(relative: 100 * T.ulpOfOne)
    testSpecials(relative: 1 * T.ulpOfOne)
    testSpecials(relative: 100 as T)
  }
  
  func testFloat() {
    testSpecials(Float.self)
  }
  
  func testDouble() {
    testSpecials(Double.self)
  }
  
  func testFloat80() {
    testSpecials(Float80.self)
  }
}
