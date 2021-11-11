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

public struct SplitComplexVector<RealType: Real> {
  @usableFromInline
  internal var x: UnsafeMutablePointer<RealType>
  
  @usableFromInline
  internal var y: UnsafeMutablePointer<RealType>
  
  public var count: Int {
    @_transparent didSet { owner.updateCount?(count) }
  }
  
  // The capacity of the underlying storage; zero if unknown.
  @usableFromInline
  internal var capacity: Int
  
  @usableFromInline
  internal var owner: (
    // The object that has ownership of the storage that x and y point
    // into, if the storage is owned (x and y may point into two separate
    // allocations, but they must be owned by a single object).
    object: AnyObject?,
    // If non-nil, this is called whenever count is updated, so that the
    // code responsible for deinitializing x and y knows how many elements
    // of each must be cleaned up. If RealType is trivial, this is not
    // necessary.
    updateCount: ((Int) -> Void)?
  )
}

// MARK: - Low-level initializers
extension SplitComplexVector {
  
  /// Allocates a new SplitComplexVector with specified capacity, then
  /// calls the provided initializer.
  ///
  /// Note that unlike the Array method with the same name, the initializer
  /// returns the final count instead of taking it `inout`.
  @usableFromInline @inline(__always)
  internal init(
    unsafeUninitializedCapacity capacity: Int,
    initializingWith initializer: (_ x: UnsafeMutablePointer<RealType>,
                                   _ y: UnsafeMutablePointer<RealType>) -> Int
  ) {
    precondition(capacity >= 0)
    // If the capacity is large enough that we're consuming at least a
    // couple cachelines, pad it out to a multiple of 64 bytes (64 is not
    // necessarily the size of a cachline, but lines up pretty often and
    // still benefits us even when it isn't).
    if capacity * MemoryLayout<RealType>.size > 128 {
      self.capacity = (capacity + 63) & -64
    } else {
      self.capacity = capacity
    }
    // Allocate a new SplitComplexBuffer with the desired capacity and
    // call the provided initializer (which returns the count).
    let owner = SplitComplexBuffer<RealType>(uninitializedCapacity: self.capacity)
    self.x = owner.buffer.baseAddress!
    self.y = self.x.advanced(by: self.capacity)
    self.count = initializer(self.x, self.y)
    // Set owner, and register the buffer to recieve updates to count if
    // RealType is non-trivial.
    self.owner.object = owner
    if !_isPOD(RealType.self) {
      self.owner.updateCount = { newCount in owner.count = newCount }
      // didSet is not called in initializers, so we need to update the
      // count now, as well:
      owner.count = self.count
    }
  }
  
  /// Wraps existing real and imaginary memory regions in a SplitComplexVector.
  ///
  /// - Parameters:
  ///   - storage: A pair of pointers to the real and imaginary components of
  ///     the array, each containing `count` `RealType` elements stored
  ///     contiguously in memory.
  ///
  ///   - count: The number of initialized complex values in the
  ///     SplitComplexVector.
  ///
  ///   - capacity: The capacity of the buffers. If the storage does not
  ///     permit growth, set the capacity to zero or omit this parameter.
  ///
  ///   - owner: The object with ownership of the storage that the pointers
  ///     reference, and a callback to use if the count of initialized
  ///     elements in the SplitComplexVector is updated.
  ///
  ///     The SplitComplexVector will maintain a reference to the owning
  ///     object. If there is no owning object because the memory is
  ///     manually managed or the storage is immortal, omit this parameter.
  ///
  ///     If `RealType` is trivial, there is no need to provide a callback
  ///     for tracking count, because no deinitialization is required.
  ///
  /// - Returns: a `SplitComplexVector` backed by the supplied `storage`, and
  ///   holding a reference to `owner`.
  public init(
    withExistingStorage storage: (
      real: UnsafeMutablePointer<RealType>,
      imaginary: UnsafeMutablePointer<RealType>
    ),
    ownedBy owner: (
      object: AnyObject?,
      updateCount: ((Int) -> Void)?
    ) = (nil, nil),
    count: Int,
    capacity: Int = 0
  ) {
    precondition(count > 0)
    precondition(capacity == 0 || capacity > count)
    self.capacity = capacity
    self.x = storage.real
    self.y = storage.imaginary
    self.owner = owner
    self.count = count
  }
  
  /// A SplitComplexVector containing `count` copies of `value`.
  public init(repeating value: Complex<RealType>, count: Int) {
    self.init(unsafeUninitializedCapacity: count) { x, y in
      x.initialize(repeating: value.x, count: count)
      y.initialize(repeating: value.y, count: count)
      return count
    }
  }
  
  /// An empty SplitComplexVector with space reserved for `capacity` values.
  public init(capacity: Int) {
    self.init(unsafeUninitializedCapacity: capacity) { x, y in 0 }
  }
}

extension SplitComplexVector {
  @usableFromInline
  internal mutating func ensureUnique(
    minimumCapacity: Int = 0
  ) {
    if isKnownUniquelyReferenced(&owner.object) && capacity >= minimumCapacity {
      return
    }
    // Only try to grow geometrically if we're growing at all. If the
    // requested capacity is _smaller_ than what we have, simply use that.
    // TODO: allow customizing growth factor.
    let scale = minimumCapacity > capacity ? 2 : 1
    let newCapacity = Swift.max(scale*count, minimumCapacity)
    self = .init(unsafeUninitializedCapacity: newCapacity) { newx, newy in
      newx.initialize(from: x, count: count)
      newy.initialize(from: y, count: count)
      return count
    }
  }
  
  public mutating func reserveCapacity(_ newCapacity: Int) {
    if newCapacity > capacity {
      self = .init(unsafeUninitializedCapacity: newCapacity) { newx, newy in
        newx.initialize(from: x, count: count)
        newy.initialize(from: y, count: count)
        return count
      }
    }
  }
}

// MARK: - Formatting
extension SplitComplexVector: CustomStringConvertible {
  public var description: String {
    return "[" + map(\.description).joined(separator: ", ") + "]"
  }
}

extension SplitComplexVector: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Complex<RealType>...) {
    self.init(capacity: elements.count)
    self.append(contentsOf: elements)
  }
}
