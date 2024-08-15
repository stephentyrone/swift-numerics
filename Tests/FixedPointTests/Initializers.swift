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
import IntegerUtilities
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
  
  func testFloatingPointExact() {
    for i in -128 ... 127 {
      let input = Float(i)/8
      XCTAssertEqual(Int8Q3(exactly: input), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(input, rounding: .requireExact), Int8Q3(bitPattern: Int8(i)))
    }
  }
  
  func testFloatingPointRoundingDown() {
    for i in -128 ... 127 {
      let input = Float(i) / 8
      XCTAssertEqual(Int8Q3(input,                   rounding: .down), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(input.nextUp,            rounding: .down), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input + 1/16).nextDown, rounding: .down), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input + 1/16),          rounding: .down), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input + 1/16).nextUp,   rounding: .down), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input + 1/8).nextDown,  rounding: .down), Int8Q3(bitPattern: Int8(i)))
      
      XCTAssertEqual(Int8Q3(clamping: input,                   rounding: .down), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(clamping: input.nextUp,            rounding: .down), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(clamping: (input + 1/16).nextDown, rounding: .down), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(clamping: (input + 1/16),          rounding: .down), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(clamping: (input + 1/16).nextUp,   rounding: .down), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(clamping: (input + 1/8).nextDown,  rounding: .down), Int8Q3(bitPattern: Int8(i)))
    }
  }
  
  func testFloatingPointRoundingUp() {
    for i in -128 ... 127 {
      let input = Float(i) / 8
      XCTAssertEqual(Int8Q3((input - 1/8).nextUp,    rounding: .up), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input - 1/16).nextDown, rounding: .up), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input - 1/16),          rounding: .up), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input - 1/16).nextUp,   rounding: .up), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(input.nextDown,          rounding: .up), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(input,                   rounding: .up), Int8Q3(bitPattern: Int8(i)))
    }
  }
  
  func testFloatingPointRoundingTowardZero() {
    for i in -128 ... 0 {
      let input = Float(i) / 8
      XCTAssertEqual(Int8Q3((input - 1/8).nextUp,    rounding: .towardZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input - 1/16).nextDown, rounding: .towardZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input - 1/16),          rounding: .towardZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input - 1/16).nextUp,   rounding: .towardZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(input.nextDown,          rounding: .towardZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(input,                   rounding: .towardZero), Int8Q3(bitPattern: Int8(i)))
    }
    for i in 0 ... 127 {
      let input = Float(i) / 8
      XCTAssertEqual(Int8Q3(input,                   rounding: .towardZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(input.nextUp,            rounding: .towardZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input + 1/16).nextDown, rounding: .towardZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input + 1/16),          rounding: .towardZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input + 1/16).nextUp,   rounding: .towardZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input + 1/8).nextDown,  rounding: .towardZero), Int8Q3(bitPattern: Int8(i)))
    }
  }
  
  func testFloatingPointRoundingAwayFromZero() {
    for i in -128 ... -1 {
      let input = Float(i) / 8
      XCTAssertEqual(Int8Q3(input,                   rounding: .awayFromZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(input.nextUp,            rounding: .awayFromZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input + 1/16).nextDown, rounding: .awayFromZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input + 1/16),          rounding: .awayFromZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input + 1/16).nextUp,   rounding: .awayFromZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input + 1/8).nextDown,  rounding: .awayFromZero), Int8Q3(bitPattern: Int8(i)))
    }
    for i in 1 ... 127 {
      let input = Float(i) / 8
      XCTAssertEqual(Int8Q3((input - 1/8).nextUp,    rounding: .awayFromZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input - 1/16).nextDown, rounding: .awayFromZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input - 1/16),          rounding: .awayFromZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input - 1/16).nextUp,   rounding: .awayFromZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(input.nextDown,          rounding: .awayFromZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(input,                   rounding: .awayFromZero), Int8Q3(bitPattern: Int8(i)))
    }
  }
  
  func testFloatingPointRoundingToNearestOrDown() {
    for i in -128 ... 127 {
      let input = Float(i) / 8
      XCTAssertEqual(Int8Q3((input - 1/16).nextUp,   rounding: .toNearestOrDown), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(input,                   rounding: .toNearestOrDown), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input + 1/16).nextDown, rounding: .toNearestOrDown), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input + 1/16),          rounding: .toNearestOrDown), Int8Q3(bitPattern: Int8(i)))
    }
  }
  
  func testFloatingPointRoundingToNearestOrUp() {
    for i in -128 ... 127 {
      let input = Float(i) / 8
      XCTAssertEqual(Int8Q3((input - 1/16),          rounding: .toNearestOrUp), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input - 1/16).nextUp,   rounding: .toNearestOrUp), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(input,                   rounding: .toNearestOrUp), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input + 1/16).nextDown, rounding: .toNearestOrUp), Int8Q3(bitPattern: Int8(i)))
    }
  }
  
  func testFloatingPointRoundingToNearestOrZero() {
    for i in -128 ... 127 {
      let input = Float(i) / 8
      if i <= 0 {
        XCTAssertEqual(Int8Q3((input - 1/16),        rounding: .toNearestOrZero), Int8Q3(bitPattern: Int8(i)))
      }
      XCTAssertEqual(Int8Q3((input - 1/16).nextUp,   rounding: .toNearestOrZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(input,                   rounding: .toNearestOrZero), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input + 1/16).nextDown, rounding: .toNearestOrZero), Int8Q3(bitPattern: Int8(i)))
      if i >= 0 {
        XCTAssertEqual(Int8Q3((input + 1/16),        rounding: .toNearestOrZero), Int8Q3(bitPattern: Int8(i)))
      }
    }
  }
  
  func testFloatingPointRoundingToNearestOrAway() {
    for i in -128 ... 127 {
      let input = Float(i) / 8
      if i > 0 {
        XCTAssertEqual(Int8Q3((input - 1/16),        rounding: .toNearestOrAway), Int8Q3(bitPattern: Int8(i)))
      }
      XCTAssertEqual(Int8Q3((input - 1/16).nextUp,   rounding: .toNearestOrAway), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(input,                   rounding: .toNearestOrAway), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input + 1/16).nextDown, rounding: .toNearestOrAway), Int8Q3(bitPattern: Int8(i)))
      if i < 0 {
        XCTAssertEqual(Int8Q3((input + 1/16),        rounding: .toNearestOrAway), Int8Q3(bitPattern: Int8(i)))
      }
    }
  }
  
  func testFloatingPointRoundingToNearestOrEven() {
    for i in -128 ... 127 {
      let input = Float(i) / 8
      if i&1 == 0 {
        XCTAssertEqual(Int8Q3((input - 1/16),        rounding: .toNearestOrEven), Int8Q3(bitPattern: Int8(i)))
      }
      XCTAssertEqual(Int8Q3((input - 1/16).nextUp,   rounding: .toNearestOrEven), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3(input,                   rounding: .toNearestOrEven), Int8Q3(bitPattern: Int8(i)))
      XCTAssertEqual(Int8Q3((input + 1/16).nextDown, rounding: .toNearestOrEven), Int8Q3(bitPattern: Int8(i)))
      if i&1 == 0 {
        XCTAssertEqual(Int8Q3((input + 1/16),        rounding: .toNearestOrEven), Int8Q3(bitPattern: Int8(i)))
      }
    }
  }
  
  func testFloatingPointRoundingToOdd() {
    for i in -128 ... 127 {
      let input = Float(i) / 8
      if i&1 == 1 {
        XCTAssertEqual(Int8Q3((input - 1/8).nextUp, rounding: .toOdd), Int8Q3(bitPattern: Int8(i)))
      }
      XCTAssertEqual(Int8Q3(input, rounding: .toOdd), Int8Q3(bitPattern: Int8(i)))
      if i&1 == 1 {
        XCTAssertEqual(Int8Q3((input + 1/16).nextDown, rounding: .toOdd), Int8Q3(bitPattern: Int8(i)))
      }
    }
  }
  
  func testFloatingPointClamping() {
    let outOfRangeValues: [Float] = [
      .nan, -.infinity, -16.125, -16.0625, -Float(16).nextUp, -16,
      15.875, Float(15.875).nextUp, 15.9375, 16, .infinity
    ]
    for value in outOfRangeValues {
      let expected: Int8Q3 = value > 0 ? .max : .min
      XCTAssertEqual(expected, Int8Q3(clamping: value, rounding: .down))
      XCTAssertEqual(expected, Int8Q3(clamping: value, rounding: .up))
      XCTAssertEqual(expected, Int8Q3(clamping: value, rounding: .towardZero))
      XCTAssertEqual(expected, Int8Q3(clamping: value, rounding: .awayFromZero))
      XCTAssertEqual(expected, Int8Q3(clamping: value, rounding: .toNearestOrDown))
      XCTAssertEqual(expected, Int8Q3(clamping: value, rounding: .toNearestOrUp))
      XCTAssertEqual(expected, Int8Q3(clamping: value, rounding: .toNearestOrZero))
      XCTAssertEqual(expected, Int8Q3(clamping: value, rounding: .toNearestOrAway))
      XCTAssertEqual(expected, Int8Q3(clamping: value, rounding: .toNearestOrEven))
      XCTAssertEqual(expected, Int8Q3(clamping: value, rounding: .toOdd))
      XCTAssertEqual(expected, Int8Q3(clamping: value, rounding: .stochastically))
      if value == value.rounded(.towardZero) {
        XCTAssertEqual(expected, Int8Q3(clamping: value, rounding: .requireExact))
      }
    }
  }
}
