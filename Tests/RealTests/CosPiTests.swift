//===--- CosPiTests.swift -------------------------------------*- swift -*-===//
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
  func assertSame(
    _ other: Self,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    if self.isNaN && other.isNaN { return }
    // If zero, make sure we have the right zero:
    if self.isZero && other.isZero {
      if self.sign == other.sign { return }
    }
    // If non-zero and non-nan, checking equality is good enough.
    else if self == other { return }
    XCTFail("Error; expected \(other), found \(self)", file: file, line: line)
  }
  
  static func cosPiExactCases() {
    // Even integers return +1, odd integers -1. Half integers return +0.
    cos(piTimes:-8/2).assertSame(1)
    cos(piTimes:-7/2).assertSame(zero)
    cos(piTimes:-6/2).assertSame(-1)
    cos(piTimes:-5/2).assertSame(zero)
    cos(piTimes:-4/2).assertSame(1)
    cos(piTimes:-3/2).assertSame(zero)
    cos(piTimes:-2/2).assertSame(-1)
    cos(piTimes:-1/2).assertSame(zero)
    cos(piTimes:-zero).assertSame(1)
    cos(piTimes: zero).assertSame(1)
    cos(piTimes: 1/2).assertSame(zero)
    cos(piTimes: 2/2).assertSame(-1)
    cos(piTimes: 3/2).assertSame(zero)
    cos(piTimes: 4/2).assertSame(1)
    cos(piTimes: 5/2).assertSame(zero)
    cos(piTimes: 6/2).assertSame(-1)
    cos(piTimes: 7/2).assertSame(zero)
    cos(piTimes: 8/2).assertSame(1)
    
    if ulpOfOne.exponent < -16 {
      cos(piTimes:-0x1_0002.0p0).assertSame(1)
      cos(piTimes:-0x1_0001.8p0).assertSame(zero)
      cos(piTimes:-0x1_0001.0p0).assertSame(-1)
      cos(piTimes:-0x1_0000.8p0).assertSame(zero)
      cos(piTimes:-0x1_0000.0p0).assertSame(1)
      cos(piTimes:  -0xffff.8p0).assertSame(zero)
      cos(piTimes:  -0xffff.0p0).assertSame(-1)
      cos(piTimes:  -0xfffe.8p0).assertSame(zero)
      cos(piTimes:  -0xfffe.0p0).assertSame(1)
      
      cos(piTimes:   0xfffe.0p0).assertSame(1)
      cos(piTimes:   0xfffe.8p0).assertSame(zero)
      cos(piTimes:   0xffff.0p0).assertSame(-1)
      cos(piTimes:   0xffff.8p0).assertSame(zero)
      cos(piTimes: 0x1_0000.0p0).assertSame(1)
      cos(piTimes: 0x1_0000.8p0).assertSame(zero)
      cos(piTimes: 0x1_0001.0p0).assertSame(-1)
      cos(piTimes: 0x1_0001.8p0).assertSame(zero)
      cos(piTimes: 0x1_0002.0p0).assertSame(1)
    }
    
    if ulpOfOne.exponent < -32 {
      cos(piTimes:-0x1_0000_0002.0p0).assertSame(1)
      cos(piTimes:-0x1_0000_0001.8p0).assertSame(zero)
      cos(piTimes:-0x1_0000_0001.0p0).assertSame(-1)
      cos(piTimes:-0x1_0000_0000.8p0).assertSame(zero)
      cos(piTimes:-0x1_0000_0000.0p0).assertSame(1)
      cos(piTimes:  -0xffff_ffff.8p0).assertSame(zero)
      cos(piTimes:  -0xffff_ffff.0p0).assertSame(-1)
      cos(piTimes:  -0xffff_fffe.8p0).assertSame(zero)
      cos(piTimes:  -0xffff_fffe.0p0).assertSame(1)
      
      cos(piTimes:   0xffff_fffe.0p0).assertSame(1)
      cos(piTimes:   0xffff_fffe.8p0).assertSame(zero)
      cos(piTimes:   0xffff_ffff.0p0).assertSame(-1)
      cos(piTimes:   0xffff_ffff.8p0).assertSame(zero)
      cos(piTimes: 0x1_0000_0000.0p0).assertSame(1)
      cos(piTimes: 0x1_0000_0000.8p0).assertSame(zero)
      cos(piTimes: 0x1_0000_0001.0p0).assertSame(-1)
      cos(piTimes: 0x1_0000_0001.8p0).assertSame(zero)
      cos(piTimes: 0x1_0000_0002.0p0).assertSame(1)
    }
    
    // Every value with greater magnitude than this value is an integer;
    // the binade below is all half-integers.
    let a = 1 / ulpOfOne
    XCTAssertTrue(a.ulp == 1)
    cos(piTimes:-a - 2  ).assertSame(1)
    cos(piTimes:-a - 1  ).assertSame(-1)
    cos(piTimes:-a      ).assertSame(1)
    cos(piTimes:-a + 1/2).assertSame(zero)
    cos(piTimes:-a + 2/2).assertSame(-1)
    cos(piTimes:-a + 3/2).assertSame(zero)
    cos(piTimes:-a + 4/2).assertSame(1)
    cos(piTimes: a - 4/2).assertSame(1)
    cos(piTimes: a - 3/2).assertSame(zero)
    cos(piTimes: a - 2/2).assertSame(-1)
    cos(piTimes: a - 1/2).assertSame(zero)
    cos(piTimes: a      ).assertSame(1)
    cos(piTimes: a + 1  ).assertSame(-1)
    cos(piTimes: a + 2  ).assertSame(1)
    
    // Every value with greater magnitude than this value is an even
    // integer; the binade below is all integers.
    let b = Self(radix) * a
    cos(piTimes:-b.nextUp).assertSame(1)
    cos(piTimes:-b).assertSame(1)
    cos(piTimes:-b.nextDown).assertSame(-1)
    cos(piTimes: b.nextDown).assertSame(-1)
    cos(piTimes: b).assertSame(1)
    cos(piTimes: b.nextUp).assertSame(1)
    
    cos(piTimes:-greatestFiniteMagnitude).assertSame(1)
    cos(piTimes: greatestFiniteMagnitude).assertSame(1)
    
    // Non-finite values return NaN.
    cos(piTimes: nan).assertSame(nan)
    cos(piTimes:-infinity).assertSame(nan)
    cos(piTimes: infinity).assertSame(nan)
  }
}

final class CosPiTests: XCTestCase {
  func testExact() {
    Float.cosPiExactCases()
    Double.cosPiExactCases()
#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    Float80.cosPiExactCases()
#endif
  }
  
#if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
  @available(macOS 11.0, iOS 14.0, watchOS 14.0, tvOS 7.0, *)
  func testFloat16Exhaustive() {
    
    func reference(_ x: Float16) -> Float {
      let x = Float(x)
      guard x.isFinite else { return .nan }
      let n = (2*x).rounded(.toNearestOrEven)
      let f = (x - n/2)
      switch Int(n) & 3 {
      case 0: return  .cos(.pi * f)
      case 1: return f == 0 ? 0 : -.sin(.pi * f)
      case 2: return -.cos(.pi * f)
      case 3: return  .sin(.pi * f)
      default: fatalError()
      }
    }
    
    func oneValue(_ x: Float16, _ maxError: inout Float) {
      let ref = reference(x)
      let tst = Float16.cos(piTimes: x)
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
    for bits in 0 ..< UInt16(0x8000) {
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
  
#if LONG_TESTS
  func testFloatExhaustive() {
    
    func reference(_ x: Float) -> Double {
      guard x.isFinite else { return .nan }
      // All sufficiently large Float values produce 1.0.
      if x.magnitude > 0x1.0p24 { return 1 }
      // See notes above on Float16 reference implementation for discussion.
      let n = (2*x).rounded(.toNearestOrEven)
      let f = .pi * Double(x - n/2)
      switch Int(n) & 3 {
      case 0: return  .cos(f)
      case 1: return f == 0 ? 0 : -.sin(f)
      case 2: return -.cos(f)
      case 3: return  .sin(f)
      default: fatalError()
      }
    }
    
    func oneValue(_ x: Float, _ maxError: inout Double) {
      let ref = reference(x)
      let tst = Float.cos(piTimes: x)
      if ref.isNaN { XCTAssertTrue(tst.isNaN); return }
      if ref.isZero { tst.assertSame(Float(ref)); return }
      let ulp = (ref - Double(tst)).magnitude / Double(Float(ref).ulp)
      if ulp > maxError {
        print("\(ulp) ulp error @ \(x) (\(String(x.bitPattern, radix: 16)))")
        maxError = ulp
      }
    }
    
    var maxError: Double = 0.49
    for bits in 0 ..< UInt32(0x8000_0000) {
      oneValue( Float(bitPattern: bits), &maxError)
      oneValue(-Float(bitPattern: bits), &maxError)
    }
    
    print("Worst error was \(maxError) ulps.")
    XCTAssertLessThan(maxError, 2.0)
  }
#endif
  
  func testFloatPerformance_m2_2() {
    let data = (0 ..< 1024).map { _ in Float.random(in: -2 ... 2) }
    let clock = SuspendingClock()
    
    var throughput = [Duration]()
    for _ in 0 ..< 100 {
      let time = clock.measure {
        for val in data {
          blackHole(Float.cos(piTimes: val))
        }
      }
      throughput.append(time * 1/1024.0)
    }
    print("Throughput: \(throughput.min()!) / element")
    
#if arch(arm64) || arch(x86_64)
    var latency = [Duration]()
    for _ in 0 ..< 100 {
      let time = clock.measure {
        var carry: Float = 0
        for val in data {
          carry = Float.cos(piTimes: val.insertDependency(on: carry))
        }
        blackHole(carry)
      }
      latency.append(time * 1/1024.0)
    }
    print("Latency: \(latency.min()!) / element")
#endif
  }
  
  func testDoublePerformance_m2_2() {
    let data = (0 ..< 1024).map { _ in Double.random(in: -2 ... 2) }
    let clock = SuspendingClock()
    
    var throughput = [Duration]()
    for _ in 0 ..< 100 {
      let time = clock.measure {
        for val in data {
          blackHole(Double.cos(piTimes: val))
        }
      }
      throughput.append(time * 1/1024.0)
    }
    print("Throughput: \(throughput.min()!) / element")
    
#if arch(arm64)
    var latency = [Duration]()
    for _ in 0 ..< 100 {
      let time = clock.measure {
        var carry: Double = 0
        for val in data {
          carry = Double.cos(piTimes: val.insertDependency(on: carry))
        }
        blackHole(carry)
      }
      latency.append(time * 1/1024.0)
    }
    print("Latency: \(latency.min()!) / element")
#endif
  }
}
