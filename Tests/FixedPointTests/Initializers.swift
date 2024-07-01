//===--- Initializers.swift -----------------------------------*- swift -*-===//
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

final class InitializerTests: XCTestCase {
  func testIntegerLiterals() {
    XCTAssertEqual(-33554432, Int32Q6(bitPattern:  .min))
    XCTAssertEqual(-33554431, Int32Q6(bitPattern: -0x7fffffc0))
    XCTAssertEqual(-1,        Int32Q6(bitPattern: -0x40))
    XCTAssertEqual( 0,        Int32Q6(bitPattern:  0x00))
    XCTAssertEqual( 1,        Int32Q6(bitPattern:  0x40))
    XCTAssertEqual( 33554431, Int32Q6(bitPattern:  0x7fffffc0))
  }
  
  func testFloatingPointLiterals() {
    XCTAssertEqual(-0x8000_0000.8p-6,       Int32Q6(bitPattern:  .min))       // 1 ulp inside overflow boundary
    XCTAssertEqual(-0x8000_0000.0p-6,       Int32Q6(bitPattern:  .min))
    XCTAssertEqual(-0x7fff_ffff.8p-6,       Int32Q6(bitPattern:  .min))
    XCTAssertEqual(-0x7fff_ffff.7fff_fcp-6, Int32Q6(bitPattern: -0x7fffffff))
    XCTAssertEqual(-0x7fff_ffff.0p-6,       Int32Q6(bitPattern: -0x7fffffff))
    XCTAssertEqual(-0x7fff_fffe.8000_04p-6, Int32Q6(bitPattern: -0x7fffffff))
    XCTAssertEqual(-0x7fff_fffe.8p-6,       Int32Q6(bitPattern: -0x7ffffffe))
    
    XCTAssertEqual(-0x40.0p-6,              Int32Q6(bitPattern: -64))
    XCTAssertEqual(-0x3f.8p-6,              Int32Q6(bitPattern: -64))
    XCTAssertEqual(-0x3f.7fff_ffff_fffep-6, Int32Q6(bitPattern: -63))
    XCTAssertEqual(-0x1.0p-6,               Int32Q6(bitPattern: -1))
    XCTAssertEqual(-0x1.0000_0000_00008p-7, Int32Q6(bitPattern: -1))
    XCTAssertEqual(-0x1.0p-7,               Int32Q6(bitPattern:  0))
    XCTAssertEqual(-0x1.0p-1022,            Int32Q6(bitPattern:  0))
    XCTAssertEqual(-0x1.0p-1074,            Int32Q6(bitPattern:  0))
    XCTAssertEqual(-0.0,                    Int32Q6(bitPattern:  0))
    XCTAssertEqual( 0.0,                    Int32Q6(bitPattern:  0))
    XCTAssertEqual( 0x1.0p-1074,            Int32Q6(bitPattern:  0))
    XCTAssertEqual( 0x1.0p-1022,            Int32Q6(bitPattern:  0))
    XCTAssertEqual( 0x1.0p-7,               Int32Q6(bitPattern:  0))
    XCTAssertEqual( 0x1.0000_0000_00008p-7, Int32Q6(bitPattern:  1))
    XCTAssertEqual( 0x1.0p-6,               Int32Q6(bitPattern:  1))
    XCTAssertEqual( 0x3f.7fff_ffff_fffep-6, Int32Q6(bitPattern:  63))
    XCTAssertEqual( 0x3f.8p-6,              Int32Q6(bitPattern:  64))
    XCTAssertEqual( 0x40.0p-6,              Int32Q6(bitPattern:  64))
    
    XCTAssertEqual( 0x7fff_fffe.8p-6,       Int32Q6(bitPattern:  0x7ffffffe))
    XCTAssertEqual( 0x7fff_fffe.8000_04p-6, Int32Q6(bitPattern:  0x7fffffff))
    XCTAssertEqual( 0x7fff_ffff.0p-6,       Int32Q6(bitPattern:  0x7fffffff))
    XCTAssertEqual( 0x7fff_ffff.7fff_fcp-6, Int32Q6(bitPattern:  0x7fffffff)) // 1 ulp inside overflow boundary
  }
}
