//===--- TanPiTests.swift -------------------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import RealModule
import XCTest
import _TestSupport

extension Real where Self: BinaryFloatingPoint {
  
  static func tanPiExactCases() {
    // Integers return copysign(0, self). Half-integers return ±1.
    tan(piTimes:-8/4).assertSame(-zero)
    tan(piTimes:-7/4).assertSame(-1)
    tan(piTimes:-6/4).assertSame( infinity)
    tan(piTimes:-5/4).assertSame( 1)
    tan(piTimes:-4/4).assertSame( zero)
    tan(piTimes:-3/4).assertSame(-1)
    tan(piTimes:-2/4).assertSame(-infinity)
    tan(piTimes:-1/4).assertSame(-1)
    tan(piTimes:-zero).assertSame(-zero)
    tan(piTimes: zero).assertSame( zero)
    tan(piTimes: 1/4).assertSame( 1)
    tan(piTimes: 2/4).assertSame( infinity)
    tan(piTimes: 3/4).assertSame(-1)
    tan(piTimes: 4/4).assertSame(-zero)
    tan(piTimes: 5/4).assertSame( 1)
    tan(piTimes: 6/4).assertSame(-infinity)
    tan(piTimes: 7/4).assertSame(-1)
    tan(piTimes: 8/4).assertSame( zero)
    
    if ulpOfOne.exponent < -16 {
      tan(piTimes:-0x1_0002.0p0).assertSame(-zero)
      tan(piTimes:-0x1_0001.8p0).assertSame( infinity)
      tan(piTimes:-0x1_0001.0p0).assertSame(-zero)
      tan(piTimes:-0x1_0000.8p0).assertSame(-1)
      tan(piTimes:-0x1_0000.0p0).assertSame(-zero)
      tan(piTimes:  -0xffff.8p0).assertSame( 1)
      tan(piTimes:  -0xffff.0p0).assertSame(-zero)
      tan(piTimes:  -0xfffe.8p0).assertSame(-1)
      tan(piTimes:  -0xfffe.0p0).assertSame(-zero)
      
      tan(piTimes:   0xfffe.0p0).assertSame(zero)
      tan(piTimes:   0xfffe.8p0).assertSame( 1)
      tan(piTimes:   0xffff.0p0).assertSame(zero)
      tan(piTimes:   0xffff.8p0).assertSame(-1)
      tan(piTimes: 0x1_0000.0p0).assertSame(zero)
      tan(piTimes: 0x1_0000.8p0).assertSame( 1)
      tan(piTimes: 0x1_0001.0p0).assertSame(zero)
      tan(piTimes: 0x1_0001.8p0).assertSame(-1)
      tan(piTimes: 0x1_0002.0p0).assertSame(zero)
    }
    
    if ulpOfOne.exponent < -32 {
      tan(piTimes:-0x1_0000_0002.0p0).assertSame(-zero)
      tan(piTimes:-0x1_0000_0001.8p0).assertSame( 1)
      tan(piTimes:-0x1_0000_0001.0p0).assertSame(-zero)
      tan(piTimes:-0x1_0000_0000.8p0).assertSame(-1)
      tan(piTimes:-0x1_0000_0000.0p0).assertSame(-zero)
      tan(piTimes:  -0xffff_ffff.8p0).assertSame( 1)
      tan(piTimes:  -0xffff_ffff.0p0).assertSame(-zero)
      tan(piTimes:  -0xffff_fffe.8p0).assertSame(-1)
      tan(piTimes:  -0xffff_fffe.0p0).assertSame(-zero)
      
      tan(piTimes:   0xffff_fffe.0p0).assertSame(zero)
      tan(piTimes:   0xffff_fffe.8p0).assertSame( 1)
      tan(piTimes:   0xffff_ffff.0p0).assertSame(zero)
      tan(piTimes:   0xffff_ffff.8p0).assertSame(-1)
      tan(piTimes: 0x1_0000_0000.0p0).assertSame(zero)
      tan(piTimes: 0x1_0000_0000.8p0).assertSame( 1)
      tan(piTimes: 0x1_0000_0001.0p0).assertSame(zero)
      tan(piTimes: 0x1_0000_0001.8p0).assertSame(-1)
      tan(piTimes: 0x1_0000_0002.0p0).assertSame(zero)
    }
    
    // Every value with greater magnitude than this value is an integer;
    // the binade below is all half-integers.
    let a = 1 / ulpOfOne
    XCTAssertTrue(a.ulp == 1)
    tan(piTimes:-a - 2  ).assertSame(-zero)
    tan(piTimes:-a - 1  ).assertSame(-zero)
    tan(piTimes:-a      ).assertSame(-zero)
    tan(piTimes:-a + 1/2).assertSame( 1)
    tan(piTimes:-a + 2/2).assertSame(-zero)
    tan(piTimes:-a + 3/2).assertSame(-1)
    tan(piTimes:-a + 4/2).assertSame(-zero)
    tan(piTimes: a - 4/2).assertSame( zero)
    tan(piTimes: a - 3/2).assertSame( 1)
    tan(piTimes: a - 2/2).assertSame( zero)
    tan(piTimes: a - 1/2).assertSame(-1)
    tan(piTimes: a      ).assertSame( zero)
    tan(piTimes: a + 1  ).assertSame( zero)
    tan(piTimes: a + 2  ).assertSame( zero)
    
    tan(piTimes:-greatestFiniteMagnitude).assertSame(-zero)
    tan(piTimes: greatestFiniteMagnitude).assertSame( zero)
    
    // Non-finite values return NaN.
    tan(piTimes: nan).assertSame(nan)
    tan(piTimes:-infinity).assertSame(nan)
    tan(piTimes: infinity).assertSame(nan)
  }
}

final class TanPiTests: XCTestCase {
  func testExact() {
    // Float16 is only available on macOS when targeting arm64.
#if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
    if #available(macOS 11.0, iOS 14.0, watchOS 14.0, tvOS 7.0, *) {
      Float16.tanPiExactCases()
    }
#endif
    Float.tanPiExactCases()
    Double.tanPiExactCases()
#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    Float80.tanPiExactCases()
#endif
  }
}
