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
  @usableFromInline
  internal var x: UnsafeMutablePointer<RealType>
  
  @usableFromInline
  internal var y: UnsafeMutablePointer<RealType>
  
  public var count: Int
  
  // The capacity of the underlying storage; zero if unknown.
  @usableFromInline
  internal var capacity: Int
  
  internal var owner: AnyObject?
}

extension SplitComplexArray {
  /// A SplitComplexArray containing `count` copies of `value`.
  public init(repeating value: Complex<RealType>, count: Int) {
    self.init(unsafeUninitializedCapacity: count) { x, y in
      x.initialize(repeating: value.x, count: count)
      y.initialize(repeating: value.y, count: count)
      return count
    }
  }
  
  @usableFromInline
  internal mutating func ensureUnique(
    minimumCapacity: Int = 0
  ) {
    if isKnownUniquelyReferenced(&owner) && capacity >= minimumCapacity {
      return
    }
    // Only try to grow geometrically if we're growing at all. If the
    // requested capacity is _smaller_ than what we have, simply use that.
    // TODO: allow customizing growth factor.
    let scale = minimumCapacity > capacity ? 2 : 1
    capacity = Swift.max(scale*count, minimumCapacity)
    // Allocate buffer with new capacity.
    let owner = UnsafeBufferOwner<RealType>(uninitializedCapacity: 2*capacity)
    // copy x and y data before we update the layout information of self,
    // because we need to have the old layout information to find the
    // memory to copy from. Old x and y allocations are not necessarily
    // contiguous, so we need to copy them separately.
    let newx = owner.buffer.baseAddress!
    let newy = newx.advanced(by: capacity)
    newx.initialize(from: x, count: count)
    newy.initialize(from: y, count: count)
    // Data has been copied, so we can update layout info (count does not
    // change).
    self.x = newx
    self.y = newy
    self.owner = owner
  }
}

// MARK: - Raw pointer operations
extension SplitComplexArray {
  // TODO: should we have an init that takes UMBP as well as / instead of this?
  /// Wraps existing real and imaginary memory regions in a SplitComplexArray.
  ///
  /// - Parameters:
  ///   - storage: A pair of pointers to the real and imaginary components of
  ///     the array, each containing `count` `RealType` elements stored
  ///     contiguously in memory.
  ///   - count: The number of complex values in the SplitComplexArray.
  ///   - capacity: The capacity of the buffers. If the storage does not
  ///     permit growth, set the capacity to zero or omit this parameter.
  ///   - owner: The object with ownership of the storage that the pointers
  ///     reference. The SplitComplexArray will maintain a reference to this
  ///     object. If there is no owning object because the memory is manually
  ///     managed or the storage is immortal, omit this parameter.
  ///
  /// - Returns: a `SplitComplexArray` backed by the supplied `storage`, and
  ///   holding a reference to `owner`.
  public init(
    withExistingStorage storage: (real: UnsafeMutablePointer<RealType>,
                                  imaginary: UnsafeMutablePointer<RealType>),
    count: Int,
    capacity: Int = 0,
    ownedBy owner: AnyObject? = nil
  ) {
    precondition(count > 0)
    precondition(capacity == 0 || capacity > count)
    self.count = count
    self.capacity = capacity
    self.x = storage.real
    self.y = storage.imaginary
    self.owner = owner
  }
  
  @usableFromInline @inline(__always)
  internal init(
    unsafeUninitializedCapacity capacity: Int,
    initializingWith initializer: (UnsafeMutablePointer<RealType>,
                                   UnsafeMutablePointer<RealType>) -> Int
  ) {
    precondition(capacity >= 0)
    let owner = UnsafeBufferOwner<RealType>(uninitializedCapacity: 2*capacity)
    self.capacity = capacity
    self.x = owner.buffer.baseAddress!
    self.y = self.x.advanced(by: capacity)
    self.owner = owner
    self.count = initializer(self.x, self.y)
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
