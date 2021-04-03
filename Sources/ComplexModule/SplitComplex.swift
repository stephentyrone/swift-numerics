//===--- SplitComplex.swift -----------------------------------*- swift -*-===//
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

public struct SplitComplexArray<RealType> where RealType: Real {
  
  internal var x: [RealType]
  
  internal var y: [RealType]
  
  public init() {
    x = []
    y = []
  }
}

extension SplitComplexArray: MutableCollection, RangeReplaceableCollection {
  
  public typealias Element = Complex<RealType>
  
  public typealias Index = Int
  
  public var startIndex: Int { x.startIndex }
  
  public var endIndex: Int { x.endIndex }
  
  public func index(after i: Int) -> Int {
    return x.index(after: i)
  }
  
  public subscript(i: Int) -> Complex<RealType> {
    _read {
      yield Complex(x[i], y[i])
    }
    _modify {
      var tmp = Complex(x[i], y[i])
      yield &tmp
      self.x[i] = tmp.x
      self.y[i] = tmp.y
    }
  }
  
  public mutating func replaceSubrange<C>(_ range: Range<Index>, with newElements: C)
  where C: Collection, C.Element == Complex<RealType> {
    x.replaceSubrange(range, with: newElements.map { $0.x })
    y.replaceSubrange(range, with: newElements.map { $0.y })
  }
}

extension SplitComplexArray {
  public func withUnsafeBufferPointers<R>(
    _ body: (_ real: UnsafeBufferPointer<RealType>,
             _ imag: UnsafeBufferPointer<RealType>) throws -> R
  ) rethrows -> R {
    try x.withUnsafeBufferPointer { r in
      try y.withUnsafeBufferPointer { i in
        try body(r,i)
      }
    }
  }
  
  public mutating func withUnsafeMutableBufferPointers<R>(
    _ body: (_ real: inout UnsafeMutableBufferPointer<RealType>,
             _ imag: inout UnsafeMutableBufferPointer<RealType>) throws -> R
  ) rethrows -> R {
    try x.withUnsafeMutableBufferPointer { r in
      try y.withUnsafeMutableBufferPointer { i in
        try body(&r, &i)
      }
    }
  }
}

#if canImport(Accelerate)
import Accelerate

extension SplitComplexArray where RealType == Float {
  public mutating func withUnsafeDSPSplitComplex<R>(
    _ body: (_ split: DSPSplitComplex, _ n: Int) throws -> R
  ) rethrows -> R {
    try withUnsafeMutableBufferPointers { (r,i) in
      try body(
        DSPSplitComplex(realp: r.baseAddress!, imagp: i.baseAddress!),
        r.count
      )
    }
  }
}
#endif
