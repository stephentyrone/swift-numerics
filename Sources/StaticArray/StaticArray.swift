//===--- StaticArray.swift ------------------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

/// A fixed-size object that can be interpreted as a collection of `count`x`Element`.
///
/// The underlying storage for a type conforming to this protocol can be anything, subject to the following
/// requirement that it have the same size and alignment as a tuple of `count` `Element`s.
///
/// All necessary methods for RandomAccess and MutableCollection are defaulted, as well as a
/// `subscript[unchecked:]` and the `withUnsafe[Mutable]BufferPointer` methods.
/// Conforming types should not implement these methods.
public protocol StaticArray: RandomAccessCollection, MutableCollection where Index == Int {
  /// Initialize with element values taken from an iterator.
  ///
  /// It is an error if the iterator runs out of values before this container is full. It is *not* an error for the
  /// iterator to yeild more elements than the container allows. This initializer is a detail used to implement
  /// `init<S:Sequence>(_: S)` and `init(_: (Int) -> Element)`.
  init<I>(_iterator iter: inout I) where I: IteratorProtocol, I.Element == Element
  
  /// Initialize with a function mapping from index to element value.
  init(_startIndex: Int, _ function: (Int) -> Element)
}

// MARK: - Functionality introduced by conformance to StaticArray
extension StaticArray {
  
  // Static version of `.count`, since these are fixed-size aggregates.
  @_transparent
  public static var count: Int {
    MemoryLayout<Self>.stride / MemoryLayout<Element>.stride
  }
  
  // Static version of `.indices`, since these are fixed-size aggregates.
  @_transparent
  public static var indices: Range<Int> {
    0 ..< count
  }
  
  /// Constructs an aggregate with the specified element repeated.
  @_transparent
  public init(repeating value: Element) {
    self.init({ _ in value })
  }
  
  @_transparent
  public init(_ function: (Int) -> Element) {
    self.init(_startIndex: 0, function)
  }
  
  @_transparent
  public init<S>(_ sequence: S) where S: Sequence, S.Element == Element {
    var iter = sequence.makeIterator()
    self.init(_iterator: &iter)
    precondition(iter.next() == nil, "Too many elements in sequence.")
  }
  
  public subscript(unchecked index: Int) -> Element {
    @_transparent
    get { withUnsafeBufferPointer { $0[index] } }
    @_transparent
    set { withUnsafeMutableBufferPointer { $0[index] = newValue } }
  }
  
  @_transparent
  public func withUnsafeBufferPointer<R>(
    _ body: (UnsafeBufferPointer<Element>) throws -> R
  ) rethrows -> R {
    try withUnsafePointer(to: self) {
      try $0.withMemoryRebound(to: Element.self, capacity: Self.count) {
        try body(UnsafeBufferPointer<Element>(start: $0, count:  Self.count))
      }
    }
  }
  
  @_transparent
  public mutating func withUnsafeMutableBufferPointer<R>(
    _ body: (UnsafeMutableBufferPointer<Element>) throws -> R
  ) rethrows -> R {
    try withUnsafeMutablePointer(to: &self) {
      try $0.withMemoryRebound(to: Element.self, capacity:  Self.count) {
        try body(UnsafeMutableBufferPointer<Element>(start: $0, count: Self.count))
      }
    }
  }
}

// MARK: - RandomAccess / MutableCollection conformances
extension StaticArray {
  @_transparent
  public var startIndex: Int { 0 }
  
  @_transparent
  public var endIndex: Int { Self.count }
  
  public subscript(index: Int) -> Element {
    @_transparent
    get {
      precondition(index >= startIndex && index <= endIndex)
      return self[unchecked: index]
    }
    @_transparent
    set {
      precondition(index >= startIndex && index <= endIndex)
      self[unchecked: index] = newValue
    }
  }
}

// MARK: - Hashable / Equatable when Element is
extension StaticArray where Element: Equatable {
  @_transparent
  public static func ==(_ a: Self, _ b: Self) -> Bool {
    var result = true
    for i in indices {
      if a[i] != b[i] { result = false }
    }
    return result
  }
}

extension StaticArray where Element: Hashable {
  @_transparent
  public func hash(into hasher: inout Hasher) {
    for i in indices {
      hasher.combine(self[i])
    }
  }
}

/// A fixed-size array holding exactly one element.
///
/// You'll rarely use this directly,; it's a necessary base case to build larger fixed-size aggregates.
@frozen
public struct Array1<Element>: StaticArray {
  public typealias Index = Int
  
  @usableFromInline
  internal var storage: Element
  
  @_transparent
  public init(_startIndex: Int, _ function: (Int) -> Element) {
    storage = function(_startIndex)
  }
  
  @_transparent
  public init<I>(_iterator iter: inout I) where I : IteratorProtocol, Element == I.Element {
    storage = iter.next()!
  }
}

/// Adjoins two StaticArrays with the same element type to form a larger aggregate.
///
/// You'll rarely use this directly; we use it to build up useful types that we give meaningful names.
@frozen
public struct Adjoin<A: StaticArray, B: StaticArray>: StaticArray
where A.Element == B.Element {
  public typealias Index = Int
  public typealias Element = A.Element
  
  @usableFromInline
  internal var a: A
  
  @usableFromInline
  internal var b: B
  
  @_transparent
  public init(_startIndex: Int, _ function: (Int) -> Element) {
    a = A(_startIndex: _startIndex, function)
    b = B(_startIndex: _startIndex + A.count, function)
  }
  
  @_transparent
  public init<I>(_iterator iter: inout I) where I : IteratorProtocol, Element == I.Element {
    a = A(_iterator: &iter)
    b = B(_iterator: &iter)
  }
}

public typealias  Array2<Element> = Adjoin<Array1<Element>, Array1<Element>>
public typealias  Array3<Element> = Adjoin<Array2<Element>, Array1<Element>>
public typealias  Array4<Element> = Adjoin<Array2<Element>, Array2<Element>>
public typealias  Array5<Element> = Adjoin<Array4<Element>, Array1<Element>>
public typealias  Array6<Element> = Adjoin<Array4<Element>, Array2<Element>>
public typealias  Array7<Element> = Adjoin<Array4<Element>, Array3<Element>>
public typealias  Array8<Element> = Adjoin<Array4<Element>, Array4<Element>>
public typealias  Array9<Element> = Adjoin<Array8<Element>, Array1<Element>>
public typealias Array10<Element> = Adjoin<Array8<Element>, Array2<Element>>
public typealias Array11<Element> = Adjoin<Array8<Element>, Array3<Element>>
public typealias Array12<Element> = Adjoin<Array8<Element>, Array4<Element>>
public typealias Array13<Element> = Adjoin<Array8<Element>, Array5<Element>>
public typealias Array14<Element> = Adjoin<Array8<Element>, Array6<Element>>
public typealias Array15<Element> = Adjoin<Array8<Element>, Array7<Element>>
public typealias Array16<Element> = Adjoin<Array8<Element>, Array8<Element>>
