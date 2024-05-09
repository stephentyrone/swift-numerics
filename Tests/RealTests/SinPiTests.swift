//===--- SinPiTests.swift -------------------------------------*- swift -*-===//
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
  
  static func sinPiExactCases() {
    // Integers return copysign(0, self). Half-integers return ±1.
    sin(piTimes:-8/2).assertSame(-zero)
    sin(piTimes:-7/2).assertSame( 1)
    sin(piTimes:-6/2).assertSame(-zero)
    sin(piTimes:-5/2).assertSame(-1)
    sin(piTimes:-4/2).assertSame(-zero)
    sin(piTimes:-3/2).assertSame( 1)
    sin(piTimes:-2/2).assertSame(-zero)
    sin(piTimes:-1/2).assertSame(-1)
    sin(piTimes:-zero).assertSame(-zero)
    sin(piTimes: zero).assertSame( zero)
    sin(piTimes: 1/2).assertSame( 1)
    sin(piTimes: 2/2).assertSame( zero)
    sin(piTimes: 3/2).assertSame(-1)
    sin(piTimes: 4/2).assertSame( zero)
    sin(piTimes: 5/2).assertSame( 1)
    sin(piTimes: 6/2).assertSame( zero)
    sin(piTimes: 7/2).assertSame(-1)
    sin(piTimes: 8/2).assertSame( zero)
    
    if ulpOfOne.exponent < -16 {
      sin(piTimes:-0x1_0002.0p0).assertSame(-zero)
      sin(piTimes:-0x1_0001.8p0).assertSame( 1)
      sin(piTimes:-0x1_0001.0p0).assertSame(-zero)
      sin(piTimes:-0x1_0000.8p0).assertSame(-1)
      sin(piTimes:-0x1_0000.0p0).assertSame(-zero)
      sin(piTimes:  -0xffff.8p0).assertSame( 1)
      sin(piTimes:  -0xffff.0p0).assertSame(-zero)
      sin(piTimes:  -0xfffe.8p0).assertSame(-1)
      sin(piTimes:  -0xfffe.0p0).assertSame(-zero)
      
      sin(piTimes:   0xfffe.0p0).assertSame(zero)
      sin(piTimes:   0xfffe.8p0).assertSame( 1)
      sin(piTimes:   0xffff.0p0).assertSame(zero)
      sin(piTimes:   0xffff.8p0).assertSame(-1)
      sin(piTimes: 0x1_0000.0p0).assertSame(zero)
      sin(piTimes: 0x1_0000.8p0).assertSame( 1)
      sin(piTimes: 0x1_0001.0p0).assertSame(zero)
      sin(piTimes: 0x1_0001.8p0).assertSame(-1)
      sin(piTimes: 0x1_0002.0p0).assertSame(zero)
    }
    
    if ulpOfOne.exponent < -32 {
      sin(piTimes:-0x1_0000_0002.0p0).assertSame(-zero)
      sin(piTimes:-0x1_0000_0001.8p0).assertSame( 1)
      sin(piTimes:-0x1_0000_0001.0p0).assertSame(-zero)
      sin(piTimes:-0x1_0000_0000.8p0).assertSame(-1)
      sin(piTimes:-0x1_0000_0000.0p0).assertSame(-zero)
      sin(piTimes:  -0xffff_ffff.8p0).assertSame( 1)
      sin(piTimes:  -0xffff_ffff.0p0).assertSame(-zero)
      sin(piTimes:  -0xffff_fffe.8p0).assertSame(-1)
      sin(piTimes:  -0xffff_fffe.0p0).assertSame(-zero)
      
      sin(piTimes:   0xffff_fffe.0p0).assertSame(zero)
      sin(piTimes:   0xffff_fffe.8p0).assertSame( 1)
      sin(piTimes:   0xffff_ffff.0p0).assertSame(zero)
      sin(piTimes:   0xffff_ffff.8p0).assertSame(-1)
      sin(piTimes: 0x1_0000_0000.0p0).assertSame(zero)
      sin(piTimes: 0x1_0000_0000.8p0).assertSame( 1)
      sin(piTimes: 0x1_0000_0001.0p0).assertSame(zero)
      sin(piTimes: 0x1_0000_0001.8p0).assertSame(-1)
      sin(piTimes: 0x1_0000_0002.0p0).assertSame(zero)
    }
    
    // Every value with greater magnitude than this value is an integer;
    // the binade below is all half-integers.
    let a = 1 / ulpOfOne
    XCTAssertTrue(a.ulp == 1)
    sin(piTimes:-a - 2  ).assertSame(-zero)
    sin(piTimes:-a - 1  ).assertSame(-zero)
    sin(piTimes:-a      ).assertSame(-zero)
    sin(piTimes:-a + 1/2).assertSame( 1)
    sin(piTimes:-a + 2/2).assertSame(-zero)
    sin(piTimes:-a + 3/2).assertSame(-1)
    sin(piTimes:-a + 4/2).assertSame(-zero)
    sin(piTimes: a - 4/2).assertSame( zero)
    sin(piTimes: a - 3/2).assertSame( 1)
    sin(piTimes: a - 2/2).assertSame( zero)
    sin(piTimes: a - 1/2).assertSame(-1)
    sin(piTimes: a      ).assertSame( zero)
    sin(piTimes: a + 1  ).assertSame( zero)
    sin(piTimes: a + 2  ).assertSame( zero)
    
    sin(piTimes:-greatestFiniteMagnitude).assertSame(-zero)
    sin(piTimes: greatestFiniteMagnitude).assertSame( zero)
    
    // Non-finite values return NaN.
    sin(piTimes: nan).assertSame(nan)
    sin(piTimes:-infinity).assertSame(nan)
    sin(piTimes: infinity).assertSame(nan)
  }
}

final class SinPiTests: XCTestCase {
  func testExact() {
    // Float16 is only available on macOS when targeting arm64.
#if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
    if #available(macOS 11.0, iOS 14.0, watchOS 14.0, tvOS 7.0, *) {
      Float16.sinPiExactCases()
    }
#endif
    Float.sinPiExactCases()
    Double.sinPiExactCases()
#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    Float80.sinPiExactCases()
#endif
  }
  
#if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
  @available(macOS 11.0, iOS 14.0, watchOS 14.0, tvOS 7.0, *)
  func testFloat16Exhaustive() {
    
    func reference(_ x: Float16) -> Float {
      // If x is negative, compute sin(-πx), then flip the sign.
      if x.sign == .minus { return -reference(x.magnitude) }
      let x = Float(x)
      guard x.isFinite else { return .nan }
      let n = (2*x).rounded(.toNearestOrEven)
      let f = (x - n/2)
      switch Int(n) & 3 {
      case 0: return  .sin(.pi * f)
      case 1: return  .cos(.pi * f)
      case 2: return f == 0 ? 0 : -sin(.pi * f)
      case 3: return -.cos(.pi * f)
      default: fatalError()
      }
    }
    
    func oneValue(_ x: Float16, _ maxError: inout Float) {
      let ref = reference(x)
      let tst = Float16.sin(piTimes: x)
      if ref.isNaN { XCTAssertTrue(tst.isNaN); return }
      if ref.isZero { tst.assertSame(Float16(ref)); return }
      if tst == Float16(ref) { return }
      let ulp = (ref - Float(tst)).magnitude / Float(Float16(ref).ulp)
      if ulp > maxError {
        print("\(ulp) ulp error @ \(x) (\(String(x.bitPattern, radix: 16)))")
        print("expected \(ref)")
        print("observed \(tst)")
        maxError = ulp
      }
    }
    
    var maxError: Float = 0.0
    for bits in 0x0 ..< UInt16(0x8000) {
      oneValue( Float16(bitPattern: bits), &maxError)
      oneValue(-Float16(bitPattern: bits), &maxError)
    }
    
    print("Worst error was \(maxError) ulps.")
    XCTAssertLessThan(maxError, 0.5)
  }
  
  func testFloat16Performance_m2_2() {
    let data = (0 ..< 1024).map { _ in Float16.random(in: -2 ... 2) }
    let clock = SuspendingClock()
    
    var throughput = [Duration]()
    for _ in 0 ..< 100 {
      let time = clock.measure {
        for val in data {
          blackHole(Float16.cos(piTimes: val))
        }
      }
      throughput.append(time * 1/1024.0)
    }
    print("Throughput: \(throughput.min()!) / element")
    
#if arch(arm64) || arch(x86_64)
    var latency = [Duration]()
    for _ in 0 ..< 100 {
      let time = clock.measure {
        var carry: Float16 = 0
        for val in data {
          carry = Float16.cos(piTimes: val.insertDependency(on: carry))
        }
        blackHole(carry)
      }
      latency.append(time * 1/1024.0)
    }
    print("Latency: \(latency.min()!) / element")
#endif
  }
#endif
}
