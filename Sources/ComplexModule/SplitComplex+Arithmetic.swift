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
import _VectorPrimitives
import CoreGraphics

extension SplitComplexVector {
  @_specialize(exported: true, where RealType == Float)
  @_specialize(exported: true, where RealType == Double)
  public mutating func scale(by scale: RealType) {
    ensureUnique()
    smul(inPlace: x, scale, count)
    smul(inPlace: y, scale, count)
  }
  
  @_specialize(exported: true, where RealType == Float)
  @_specialize(exported: true, where RealType == Double)
  public mutating func unscale(by scale: RealType) {
    ensureUnique()
    if let recip = scale.reciprocal {
      smul(inPlace: x, recip, count)
      smul(inPlace: y, recip, count)
    } else {
      sdiv(inPlace: x, scale, count)
      sdiv(inPlace: y, scale, count)
    }
  }
  
  public var conjugate: SplitComplexVector {
    var result = self
    result.conj.toggle()
    return result
  }
  
  public var magnitude: RealType {
    Swift.max(
      maxmgv(x, count),
      maxmgv(y, count)
    )
  }
}

extension SplitComplexVector {
  @_specialize(exported: true, where RealType == Float)
  @_specialize(exported: true, where RealType == Double)
  public static func +=(a: inout Self, b: Self) {
    let count = a.count
    precondition(b.count == count)
    a.ensureUnique()
    vadd(inPlace: a.x, b.x, count)
    if a.conj == b.conj {
      vadd(inPlace: a.y, b.y, count)
    } else {
      vsub(inPlace: a.y, b.y, count)
    }
  }
  
  @_specialize(exported: true, where RealType == Float)
  @_specialize(exported: true, where RealType == Double)
  public static func +(a: Self, b: Self) -> Self {
    let count = a.count
    precondition(b.count == count)
    return Self(unsafeUninitializedCapacity: a.count) { x, y in
      vadd(result: x, a.x, b.x, count)
      if a.conj == b.conj {
        vadd(result: x, a.x, b.x, count)
      } else {
        vsub(result: y, a.y, b.y, count)
      }
      return a.count
    }
  }
  
  @_specialize(exported: true, where RealType == Float)
  @_specialize(exported: true, where RealType == Double)
  public static func -=(a: inout Self, b: Self) {
    let count = a.count
    precondition(b.count == count)
    a.ensureUnique()
    vsub(inPlace: a.x, b.x, count)
    if a.conj == b.conj {
      vsub(inPlace: a.y, b.y, count)
    } else {
      vadd(inPlace: a.y, b.y, count)
    }
  }
  
  @_specialize(exported: true, where RealType == Float)
  @_specialize(exported: true, where RealType == Double)
  public static func -(a: Self, b: Self) -> Self {
    let count = a.count
    precondition(b.count == count)
    return Self(unsafeUninitializedCapacity: a.count) { x, y in
      vsub(result: x, a.x, b.x, count)
      if a.conj == b.conj {
        vsub(result: x, a.x, b.x, count)
      } else {
        vadd(result: y, a.y, b.y, count)
      }
      return a.count
    }
  }
}
