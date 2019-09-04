//===--- StaticArrayTests.swift -------------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import XCTest
import StaticArray

final class StaticArrayTests: XCTestCase {
  
  func testMemoryLayout<A: StaticArray, E>(_ type: A.Type, element: E.Type, count: Int) {
    XCTAssertEqual(MemoryLayout<A>.alignment, MemoryLayout<E>.alignment)
    XCTAssertEqual(MemoryLayout<A>.stride, count * MemoryLayout<E>.stride)
    if count != 0 {
      XCTAssertEqual(MemoryLayout<A>.size, (count - 1)*MemoryLayout<E>.stride + MemoryLayout<E>.size)
    }
  }
  
  func testMemoryLayout<E>(_ type: E.Type) {
    testMemoryLayout(Array1<E>.self, element: E.self, count: 1)
    testMemoryLayout(Array2<E>.self, element: E.self, count: 2)
    testMemoryLayout(Array3<E>.self, element: E.self, count: 3)
    testMemoryLayout(Array4<E>.self, element: E.self, count: 4)
    testMemoryLayout(Array5<E>.self, element: E.self, count: 5)
    testMemoryLayout(Array6<E>.self, element: E.self, count: 6)
    testMemoryLayout(Array7<E>.self, element: E.self, count: 7)
    testMemoryLayout(Array8<E>.self, element: E.self, count: 8)
    testMemoryLayout(Array16<E>.self, element: E.self, count: 16)
  }
  
  func testMemoryLayout() {
    testMemoryLayout(Int8.self)
    testMemoryLayout(UInt32.self)
    testMemoryLayout(Int.self)
    struct NotPowerOfTwo {
      var a: UInt32
      var b: UInt8
    }
    testMemoryLayout(NotPowerOfTwo.self)
  }
  
  func testInitWithGenerator<A>(_ type: A.Type)
  where A: StaticArray, A.Element: FixedWidthInteger {
    let slide = A.Element.random(in: .min ... .max)
    func f(_ i: Int) -> A.Element { A.Element(truncatingIfNeeded: i) &+ slide }
    let a = A(f)
    if let i = A.indices.first(where: { a[$0] != f($0) }) {
      XCTFail("Wrong value for element \(i) of \(A.self). Expected \(f(i)), found \(a[i]).")
    }
  }
  
  func testInitWithGenerator<E>(_ type: E.Type) where E: FixedWidthInteger {
    testInitWithGenerator(Array1<E>.self)
    testInitWithGenerator(Array2<E>.self)
    testInitWithGenerator(Array3<E>.self)
    testInitWithGenerator(Array4<E>.self)
    testInitWithGenerator(Array7<E>.self)
    testInitWithGenerator(Array8<E>.self)
    testInitWithGenerator(Array14<E>.self)
    testInitWithGenerator(Array16<E>.self)
  }
  
  func testInitWithGenerator() {
    testInitWithGenerator(Int8.self)
    testInitWithGenerator(UInt16.self)
    testInitWithGenerator(Int.self)
    testInitWithGenerator(UInt.self)
  }
}
