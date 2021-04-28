//===--- StaticBuffer.swift -----------------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2019-2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

/// A fixed-size object that can be interpreted as a collection of
/// `count`x`Element`.
///
/// The underlying storage for a type conforming to this protocol can be
/// "anything", subject to the requirement that it is actually composed
/// of `count` `Element`s laid out contiguously in memory.
///
/// All necessary methods for RandomAccess and MutableCollection are defaulted,
/// as well as a `subscript[unchecked:]` and the `withUnsafeBufferPointer` and
/// `withUnsafeMutableBufferPointer` methods. Conforming types should not
/// implement these methods themselves.
public protocol StaticBuffer: RandomAccessCollection, MutableCollection
where Index == Int {
  /// Constructs an aggregate with the specified element repeated.
  init(repeating value: Element)
}

// MARK: - Functionality introduced by conformance to StaticBuffer
extension StaticBuffer {
  
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
      try body(UnsafeBufferPointer<Element>(
        start: UnsafeRawPointer($0).assumingMemoryBound(to: Element.self),
        count: Self.count
      ))
    }
  }
  
  @_transparent
  public mutating func withUnsafeMutableBufferPointer<R>(
    _ body: (UnsafeMutableBufferPointer<Element>) throws -> R
  ) rethrows -> R {
    try withUnsafeMutablePointer(to: &self) {
      try body(UnsafeMutableBufferPointer<Element>(
        start: UnsafeMutableRawPointer($0).assumingMemoryBound(to: Element.self),
        count: Self.count
      ))
    }
  }
}

// MARK: - RandomAccess / MutableCollection conformances
extension StaticBuffer {
  @_transparent
  public var startIndex: Int { 0 }
  
  @_transparent
  public var endIndex: Int { Self.count }
  
  public subscript(index: Int) -> Element {
    @_transparent
    get {
      precondition(indices.contains(index))
      return self[unchecked: index]
    }
    @_transparent
    set {
      precondition(indices.contains(index))
      self[unchecked: index] = newValue
    }
  }
}
