//===--- SplitComplex+Arithmetic.swift ------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import RealModule

#if canImport(Accelerate)
@_implementationOnly import Accelerate
#endif

extension SplitComplexArray {
  public func interleave() -> [Complex<RealType>] {
    #if canImport(Accelerate)
    if RealType.self == Float.self {
      var split = DSPSplitComplex(
        realp: x as! UnsafeMutablePointer<Float>,
        imagp: y as! UnsafeMutablePointer<Float>
      )
      return [Complex<RealType>](unsafeUninitializedCapacity: count) {
        p, n in
        p.withMemoryRebound(to: DSPComplex.self) {
          vDSP_ztoc(&split, 1, $0.baseAddress!, 2, vDSP_Length(count))
        }
        n = count
      }
    }
    
    if RealType.self == Double.self {
      var split = DSPDoubleSplitComplex(
        realp: x as! UnsafeMutablePointer<Double>,
        imagp: y as! UnsafeMutablePointer<Double>
      )
      return [Complex<RealType>](unsafeUninitializedCapacity: count) {
        p, n in
        p.withMemoryRebound(to: DSPDoubleComplex.self) {
          vDSP_ztocD(&split, 1, $0.baseAddress!, 2, vDSP_Length(count))
        }
        n = count
      }
    }
    #endif
    return [Complex<RealType>](self)
  }
}
