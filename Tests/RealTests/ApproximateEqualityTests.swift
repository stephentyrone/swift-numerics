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

import RealModule
import Operators
import XCTest

final class ElementaryFunctionTests: XCTestCase {
  
  func testSpecials<T: Real>(absolute tol: T) {
    let zero = T.zero
    let gfm = T.greatestFiniteMagnitude
    let inf = T.infinity
    let nan = T.nan
    XCTAssert(zero ≈  zero ± tol)
    XCTAssert(zero ≈ -zero ± tol)
    XCTAssert(inf ≉ gfm ± tol)
    XCTAssert(gfm ≉ inf ± tol)
    XCTAssert(inf ≈ inf ± tol)
    XCTAssert(-inf ≈ -inf ± tol)
    XCTAssert(inf ≉ -inf ± tol)
    XCTAssert(-inf ≉ inf ± tol)
    XCTAssert(nan ≉ nan ± tol)
  }
  
  func testSpecials<T: Real>(relative tol: T) {
    let zero = T.zero
    let gfm = T.greatestFiniteMagnitude
    let inf = T.infinity
    let nan = T.nan
    XCTAssert(zero ≈  zero ± tol%)
    XCTAssert(zero ≈ -zero ± tol%)
    XCTAssert(inf ≉ gfm ± tol%)
    XCTAssert(gfm ≉ inf ± tol%)
    XCTAssert(inf ≈ inf ± tol%)
    XCTAssert(-inf ≈ -inf ± tol%)
    XCTAssert(inf ≉ -inf ± tol%)
    XCTAssert(-inf ≉ inf ± tol%)
    XCTAssert(nan ≉ nan ± tol%)
  }
  
  func testSpecials<T: Real>(_ type: T.Type) {
    let zero = T.zero
    XCTAssert( zero ≈  zero)
    XCTAssert( zero ≈ -zero)
    XCTAssert(-zero ≈  zero)
    XCTAssert(-zero ≈ -zero)
    testSpecials(absolute: T.zero)
    testSpecials(absolute: T.leastNormalMagnitude)
    testSpecials(absolute: T.greatestFiniteMagnitude)
    testSpecials(relative: T.zero)
    testSpecials(relative: 100 * T.ulpOfOne)
    testSpecials(relative: 1 as T)
    testSpecials(relative: 100 as T)
  }

  func testDefaults<T: Real>(_ type: T.Type) {
    let e = T.ulpOfOne.squareRoot()
    XCTAssert(1 ≈ 1 + e)
    XCTAssert(1 ≈ 1 - e/2)
    XCTAssert(1 ≉ 1 + 2*e)
    XCTAssert(1 ≉ 1 - 3*e/2)
  }
  
  func testRandom<T>(_ type: T.Type) where T: FixedWidthFloatingPoint & Real {
    var g = SystemRandomNumberGenerator()
    // Generate a bunch of random values in a small interval and a tolerance
    // and use them to check that various properties that we would like to
    // hold actually do.
    var x = [1] + (0 ..< 64).map {
      _ in T.random(in: 1 ..< 2, using: &g)
    } + [2]
    x.sort()
    // We have 66 values in 1 ... 2, so if we use a tolerance of around 1/64,
    // at least some of the pairs will compare equal with tolerance.
    let abs = T.random(in: 1/64 ... 1/32, using: &g)
    let rel = (100*abs)%
    // We're going to walk the values in order, validating that some common-
    // sense properties hold.
    for i in x.indices {
      // reflexivity
      XCTAssert(x[i] ≈ x[i])
      XCTAssert(x[i] ≈ x[i] ± abs)
      XCTAssert(x[i] ≈ x[i] ± rel)
      for j in i ..< x.endIndex {
        // commutativity
        XCTAssert((x[i] ≈ x[j] ± abs) == (x[j] ≈ x[i] ± abs))
        XCTAssert((x[i] ≈ x[j] ± rel) == (x[j] ≈ x[i] ± rel))
        // scale invariance for relative comparisons
        let scale = T(
          sign:.plus,
          exponent: T.Exponent.random(in: T.leastNormalMagnitude.exponent ..< T.greatestFiniteMagnitude.exponent),
          significand: 1
        )
        XCTAssert((x[i] ≈ x[j] ± rel) == (scale*x[i] ≈ scale*x[j] ± rel))
      }
      // if a ≤ b ≤ c, and a ≈ c, then a ≈ b and b ≈ c (relative tolerance)
      var left = x.firstIndex { x[i] ≈ $0 ± rel }
      var right = x.lastIndex { x[i] ≈ $0 ± rel }
      if let l = left, let r = right {
        for j in l ..< r {
          XCTAssert(x[i] ≈ x[j] ± rel)
        }
      }
      // if a ≤ b ≤ c, and a ≈ c, then a ≈ b and b ≈ c (absolute tolerance)
      left = x.firstIndex { x[i] ≈ $0 ± abs }
      right = x.lastIndex { x[i] ≈ $0 ± abs }
      if let l = left, let r = right {
        for j in l ..< r {
          XCTAssert(x[i] ≈ x[j] ± abs)
        }
      }
    }
  }
  
  func testFloat() {
    testSpecials(Float.self)
    testDefaults(Float.self)
    testRandom(Float.self)
  }
  
  func testDouble() {
    testSpecials(Double.self)
    testDefaults(Double.self)
    testRandom(Double.self)
  }
  
  func testFloat80() {
    testSpecials(Float80.self)
    testDefaults(Float80.self)
    testRandom(Float80.self)
  }
}
