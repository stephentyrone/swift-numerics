//===--- ArithmeticCoreTests.swift ----------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import _NumericsShims
@testable import IntegerModule
import XCTest

final class IntegerCoreTests: XCTestCase {
  func testWordAddition() {
    // Random a, b such that a+b+1 does not carry.
    var a = Word.random(in: 0 ..< .max)
    var b = Word.random(in: 0 ... .max - (a + 1))
    XCTAssertEqual(a &+ b, Word.add(a, b))
    var c = false
    XCTAssertEqual(a &+ b, Word.add(a, b, &c))
    XCTAssertFalse(c)
    c = true
    XCTAssertEqual(a &+ b &+ 1, Word.add(a, b, &c))
    XCTAssertFalse(c)
    
    // a+b does not carry, but a+b+1 does.
    a = .random(in: 0 ... .max)
    b = .max - a
    XCTAssertEqual(.max, Word.add(a, b))
    c = false
    XCTAssertEqual(.max, Word.add(a, b, &c))
    XCTAssertFalse(c)
    c = true
    XCTAssertEqual(0, Word.add(a, b, &c))
    XCTAssertTrue(c)
    
    // Random a, b such that a+b carries.
    a = .random(in: 1 ... .max)
    b = .random(in: .max - a + 1 ... .max)
    XCTAssertEqual(a &+ b, Word.add(a, b))
    c = false
    XCTAssertEqual(a &+ b, Word.add(a, b, &c))
    XCTAssertTrue(c)
    XCTAssertEqual(a &+ b &+ 1, Word.add(a, b, &c))
    XCTAssertTrue(c)
  }
  
  func testWordSubtraction() {
    // Random a, b such that a-b-1 does not borrow.
    var a = Word.random(in: 1 ... .max)
    var b = Word.random(in: 0 ... a-1)
    XCTAssertEqual(a &- b, Word.sub(a, b))
    var c = false
    XCTAssertEqual(a &- b, Word.sub(a, b, &c))
    XCTAssertFalse(c)
    c = true
    XCTAssertEqual(a &- b &- 1, Word.sub(a, b, &c))
    XCTAssertFalse(c)
    
    // a-a does not borrow, but a-a-1 does.
    a = .random(in: 0 ... .max)
    XCTAssertEqual(0, Word.sub(a, a))
    c = false
    XCTAssertEqual(0, Word.sub(a, a, &c))
    XCTAssertFalse(c)
    c = true
    XCTAssertEqual(.max, Word.sub(a, a, &c))
    XCTAssertTrue(c)
    
    // Random a, b such that a-b borrows.
    a = .random(in: 0 ..< .max)
    b = .random(in: a+1 ... .max)
    XCTAssertEqual(a &- b, Word.sub(a, b))
    c = false
    XCTAssertEqual(a &- b, Word.sub(a, b, &c))
    XCTAssertTrue(c)
    XCTAssertEqual(a &- b &- 1, Word.sub(a, b, &c))
    XCTAssertTrue(c)
  }
}
