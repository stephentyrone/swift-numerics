//===--- StringTests.swift ------------------------------------*- swift -*-===//
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

final class StringTests: XCTestCase {
  func testInt8Q3() {
    XCTAssertEqual(Int8Q3(bitPattern: -0x80).description, "-16.0")
    XCTAssertEqual(Int8Q3(bitPattern: -0x7f).description, "-15.875")
    XCTAssertEqual(Int8Q3(bitPattern: -0x7e).description, "-15.75")
    XCTAssertEqual(Int8Q3(bitPattern: -0x7d).description, "-15.625")
    XCTAssertEqual(Int8Q3(bitPattern: -0x7c).description, "-15.5")
    XCTAssertEqual(Int8Q3(bitPattern: -0x7b).description, "-15.375")
    XCTAssertEqual(Int8Q3(bitPattern: -0x7a).description, "-15.25")
    XCTAssertEqual(Int8Q3(bitPattern: -0x79).description, "-15.125")
    XCTAssertEqual(Int8Q3(bitPattern: -0x78).description, "-15.0")
    XCTAssertEqual(Int8Q3(bitPattern: -0x77).description, "-14.875")
    XCTAssertEqual(Int8Q3(bitPattern: -0x76).description, "-14.75")
    XCTAssertEqual(Int8Q3(bitPattern: -0x75).description, "-14.625")
    XCTAssertEqual(Int8Q3(bitPattern: -0x74).description, "-14.5")
    XCTAssertEqual(Int8Q3(bitPattern: -0x73).description, "-14.375")
    XCTAssertEqual(Int8Q3(bitPattern: -0x72).description, "-14.25")
    XCTAssertEqual(Int8Q3(bitPattern: -0x71).description, "-14.125")
    XCTAssertEqual(Int8Q3(bitPattern: -0x70).description, "-14.0")
    XCTAssertEqual(Int8Q3(bitPattern: -0x10).description,  "-2.0")
    XCTAssertEqual(Int8Q3(bitPattern: -0x0f).description,  "-1.875")
    XCTAssertEqual(Int8Q3(bitPattern: -0x0e).description,  "-1.75")
    XCTAssertEqual(Int8Q3(bitPattern: -0x0d).description,  "-1.625")
    XCTAssertEqual(Int8Q3(bitPattern: -0x0c).description,  "-1.5")
    XCTAssertEqual(Int8Q3(bitPattern: -0x0b).description,  "-1.375")
    XCTAssertEqual(Int8Q3(bitPattern: -0x0a).description,  "-1.25")
    XCTAssertEqual(Int8Q3(bitPattern: -0x09).description,  "-1.125")
    XCTAssertEqual(Int8Q3(bitPattern: -0x08).description,  "-1.0")
    XCTAssertEqual(Int8Q3(bitPattern: -0x07).description,  "-0.875")
    XCTAssertEqual(Int8Q3(bitPattern: -0x06).description,  "-0.75")
    XCTAssertEqual(Int8Q3(bitPattern: -0x05).description,  "-0.625")
    XCTAssertEqual(Int8Q3(bitPattern: -0x04).description,  "-0.5")
    XCTAssertEqual(Int8Q3(bitPattern: -0x03).description,  "-0.375")
    XCTAssertEqual(Int8Q3(bitPattern: -0x02).description,  "-0.25")
    XCTAssertEqual(Int8Q3(bitPattern: -0x01).description,  "-0.125")
    XCTAssertEqual(Int8Q3(bitPattern:  0x00).description,   "0.0")
    XCTAssertEqual(Int8Q3(bitPattern:  0x01).description,   "0.125")
    XCTAssertEqual(Int8Q3(bitPattern:  0x02).description,   "0.25")
    XCTAssertEqual(Int8Q3(bitPattern:  0x03).description,   "0.375")
    XCTAssertEqual(Int8Q3(bitPattern:  0x04).description,   "0.5")
    XCTAssertEqual(Int8Q3(bitPattern:  0x05).description,   "0.625")
    XCTAssertEqual(Int8Q3(bitPattern:  0x06).description,   "0.75")
    XCTAssertEqual(Int8Q3(bitPattern:  0x07).description,   "0.875")
    XCTAssertEqual(Int8Q3(bitPattern:  0x08).description,   "1.0")
    XCTAssertEqual(Int8Q3(bitPattern:  0x09).description,   "1.125")
    XCTAssertEqual(Int8Q3(bitPattern:  0x0a).description,   "1.25")
    XCTAssertEqual(Int8Q3(bitPattern:  0x0b).description,   "1.375")
    XCTAssertEqual(Int8Q3(bitPattern:  0x0c).description,   "1.5")
    XCTAssertEqual(Int8Q3(bitPattern:  0x0d).description,   "1.625")
    XCTAssertEqual(Int8Q3(bitPattern:  0x0e).description,   "1.75")
    XCTAssertEqual(Int8Q3(bitPattern:  0x0f).description,   "1.875")
    XCTAssertEqual(Int8Q3(bitPattern:  0x10).description,   "2.0")
    XCTAssertEqual(Int8Q3(bitPattern:  0x70).description,  "14.0")
    XCTAssertEqual(Int8Q3(bitPattern:  0x71).description,  "14.125")
    XCTAssertEqual(Int8Q3(bitPattern:  0x72).description,  "14.25")
    XCTAssertEqual(Int8Q3(bitPattern:  0x73).description,  "14.375")
    XCTAssertEqual(Int8Q3(bitPattern:  0x74).description,  "14.5")
    XCTAssertEqual(Int8Q3(bitPattern:  0x75).description,  "14.625")
    XCTAssertEqual(Int8Q3(bitPattern:  0x76).description,  "14.75")
    XCTAssertEqual(Int8Q3(bitPattern:  0x77).description,  "14.875")
    XCTAssertEqual(Int8Q3(bitPattern:  0x78).description,  "15.0")
    XCTAssertEqual(Int8Q3(bitPattern:  0x79).description,  "15.125")
    XCTAssertEqual(Int8Q3(bitPattern:  0x7a).description,  "15.25")
    XCTAssertEqual(Int8Q3(bitPattern:  0x7b).description,  "15.375")
    XCTAssertEqual(Int8Q3(bitPattern:  0x7c).description,  "15.5")
    XCTAssertEqual(Int8Q3(bitPattern:  0x7d).description,  "15.625")
    XCTAssertEqual(Int8Q3(bitPattern:  0x7e).description,  "15.75")
    XCTAssertEqual(Int8Q3(bitPattern:  0x7f).description,  "15.875")
  }
  
  func testInt8Q7() {
    XCTAssertEqual(Int8Q7(bitPattern: -0x80).description, "-1.0")
    XCTAssertEqual(Int8Q7(bitPattern: -0x7f).description, "-0.9921875")
    XCTAssertEqual(Int8Q7(bitPattern: -0x01).description, "-0.0078125")
    XCTAssertEqual(Int8Q7(bitPattern:  0x00).description,  "0.0")
    XCTAssertEqual(Int8Q7(bitPattern:  0x01).description,  "0.0078125")
    XCTAssertEqual(Int8Q7(bitPattern:  0x7f).description,  "0.9921875")
  }
  
  func testUIntQ8() {
    XCTAssertEqual(UIntQ8(bitPattern: 0x00).description, "0.0")
    XCTAssertEqual(UIntQ8(bitPattern: 0x01).description, "0.00390625")
    XCTAssertEqual(UIntQ8(bitPattern: 0x7f).description, "0.49609375")
    XCTAssertEqual(UIntQ8(bitPattern: 0x80).description, "0.5")
    XCTAssertEqual(UIntQ8(bitPattern: 0xfe).description, "0.9921875")
    XCTAssertEqual(UIntQ8(bitPattern: 0xff).description, "0.99609375")
  }
}
