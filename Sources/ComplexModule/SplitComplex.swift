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

public struct SplitComplexArray<RealType: Real> {
  
  public var count: Int
  
  @usableFromInline
  internal var x: UnsafeMutablePointer<RealType>
  
  @usableFromInline
  internal var offset: Int
  
  internal var owner: AnyObject
}

extension SplitComplexArray {
  @usableFromInline @_transparent
  internal var y: UnsafeMutablePointer<RealType> {
    x.advanced(by: offset)
  }
  
  public init(repeating value: Complex<RealType>, count: Int) {
    precondition(count >= 0)
    let owner = UnsafeBufferOwner<RealType>(uninitializedCapacity: 2*count)
    self.count = count
    self.x = owner.buffer.baseAddress!
    self.offset = count
    self.owner = owner
    x.assign(repeating: value.x, count: count)
    y.assign(repeating: value.y, count: count)
  }
  
  @usableFromInline
  internal mutating func makeUnique() {
    if !isKnownUniquelyReferenced(&owner) {
      let owner = UnsafeBufferOwner<RealType>(uninitializedCapacity: 2*count)
      // copy x and y data before we update the layout information of self,
      // because we need to have the old layout information to find the
      // memory to copy from. Old x and y allocations are not contiguous
      // if offset != count, so we need to copy them separately.
      let newx = owner.buffer.baseAddress!
      let newy = newx.advanced(by: count)
      newx.assign(from: x, count: count)
      newy.assign(from: y, count: count)
      // Data copied, update layout info (count does not change, but offset
      // might; we compact on a copy).
      self.x = newx
      self.offset = count
      self.owner = owner
    }
  }
}

// MARK: - Collection
extension SplitComplexArray: RandomAccessCollection, MutableCollection {
  
  public typealias Index = Int
  
  public var startIndex: Index { 0 }
  
  public var endIndex: Index { count }
  
  public typealias Element = Complex<RealType>
  
  public subscript(i: Int) -> Element {
    @inlinable
    _read {
      precondition(indices.contains(i))
      yield self[unchecked: i]
    }
    @inlinable
    _modify {
      precondition(indices.contains(i))
      yield &self[unchecked: i]
    }
  }
  
  public subscript(unchecked i: Int) -> Element {
    @inlinable @inline(__always)
    _read { yield Complex(x[i], y[i]) }
    @inlinable @inline(__always)
    _modify {
      makeUnique()
      var value = Complex(x[i], y[i])
      yield &value
      x[i] = value.x
      y[i] = value.y
    }
  }
}

// MARK: - Formatting
extension SplitComplexArray: CustomStringConvertible {
  public var description: String {
    return "[" + map(\.description).joined(separator: ", ") + "]"
  }
}

// MARK: - Guts
/// A minimal "managed buffer" that doesn't do anything fancy.
@usableFromInline
internal final class UnsafeBufferOwner<Element> {
  
  var buffer: UnsafeMutableBufferPointer<Element>
  
  init(uninitializedCapacity: Int) {
    buffer = UnsafeMutableBufferPointer<Element>.allocate(
      capacity: uninitializedCapacity
    )
  }
  
  deinit { buffer.deallocate() }
}
