//===--- SplitComplex+Collection.swift ------------------------*- swift -*-===//
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

// MARK: - Collection conformances
extension SplitComplexVector: RandomAccessCollection, MutableCollection {
  
  public typealias Index = Int
  
  @inlinable
  public var startIndex: Index { 0 }
  
  @inlinable
  public var endIndex: Index { count }
  
  public typealias Element = Complex<RealType>
  
  @inlinable
  public subscript(i: Int) -> Element {
    _read {
      precondition(indices.contains(i))
      yield self[unchecked: i]
    }
    _modify {
      precondition(indices.contains(i))
      yield &self[unchecked: i]
    }
  }
  
  @inlinable @inline(__always)
  public subscript(unchecked i: Int) -> Element {
    _read {
      yield Complex(x[i], y[i])
    }
    _modify {
      ensureUnique()
      var value = Complex(x[i], y[i])
      yield &value
      x[i] = value.x
      y[i] = value.y
    }
  }
  
  public init(_ slice: Slice<SplitComplexVector<RealType>>) {
    self.init(
      withExistingStorage: (
        real: slice.base.x + slice.startIndex,
        imaginary: slice.base.y + slice.startIndex
      ),
      ownedBy: slice.base.owner,
      count: slice.count,
      capacity: 0
    )
  }
}

extension SplitComplexVector: RangeReplaceableCollection {
  public init() {
    self.init(unsafeUninitializedCapacity: 0) { x, y in 0 }
  }
  
  public mutating func replaceSubrange<Other: Collection>(
    _ subrange: Range<Int>,
    with newElements: __owned Other
  )
  where Other.Element == Complex<RealType> {
    precondition(subrange.lowerBound >= 0 && subrange.upperBound <= count,
                 "Index range out of bounds")
    let delta = newElements.count - subrange.count
    ensureUnique(minimumCapacity: count + delta)
    let lower = subrange.lowerBound
    let upper = subrange.upperBound
    // Begin by moving the tail into the right place; note that if we grew
    // the storage this results in this data being copied twice, which could
    // be improved on in the future, but does not compromise the amortized
    // complexity of array growth.
    if delta > 0 {
      (x + count).moveInitialize(from: x + count - delta, count: delta)
      (y + count).moveInitialize(from: y + count - delta, count: delta)
    }
    let tailCount = count - upper
    if tailCount > delta {
      (x + upper + delta).moveAssign(from: x + upper, count: tailCount - delta)
      (y + upper + delta).moveAssign(from: y + upper, count: tailCount - delta)
    }
    var index = newElements.startIndex
    for i in lower ..< (upper + delta) {
      if i >= upper { // self[i] is uninitialized
        (x + i).initialize(to: newElements[index].real)
        (y + i).initialize(to: newElements[index].imaginary)
      } else { // self[i] is already initialized.
        x[i] = newElements[index].real
        y[i] = newElements[index].imaginary
      }
      newElements.formIndex(after: &index)
    }
    count += delta
  }
}

// MARK: - Conversions to/from other collections
extension Array {
  /// Creates an array of `Complex` with the elements of the supplied
  /// `SplitComplexVector`.
  @inlinable
  public init<RealType>(_ split: SplitComplexVector<RealType>)
  where Element == Complex<RealType> {
    // In theory, we don't need this; the existing Array init from
    // Sequence works just fine. But it's many times slower, so we
    // provide this.
    self.init(unsafeUninitializedCapacity: split.count) {
      buffer, count in
      count = split.count
      if count != 0 {
        let dst = buffer.baseAddress!
        for i in 0 ..< count {
          (dst + i).initialize(to: split[unchecked: i])
        }
      }
    }
  }
}

extension SplitComplexVector {
  @inlinable
  public init<RAC>(_ other: RAC)
  where RAC: RandomAccessCollection, RAC.Element == Complex<RealType> {
    self.init(unsafeUninitializedCapacity: other.count) { x, y in
      var index = other.startIndex
      for i in 0 ..< other.count {
        (x + i).initialize(to: other[index].real)
        (y + i).initialize(to: other[index].imaginary)
        other.formIndex(after: &index)
      }
      return other.count
    }
  }
}
