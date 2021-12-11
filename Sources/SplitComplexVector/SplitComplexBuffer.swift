//===--- SplitComplexBuffer.swift -----------------------------*- swift -*-===//
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

// MARK: - Guts
/// A minimal "managed buffer" that doesn't do anything fancy except track
/// ownership and deallocate when needed.
@usableFromInline
internal final class SplitComplexBuffer<Element> {
  
  var buffer: UnsafeMutableBufferPointer<Element>
  
  var offset: Int
  
  @usableFromInline @inline(__always)
  var count: Int = 0
  
  init(uninitializedCapacity: Int) {
    buffer = UnsafeMutableBufferPointer<Element>.allocate(
      // Real capacity is 2x complex capacity
      capacity: 2*uninitializedCapacity
    )
    self.offset = uninitializedCapacity
  }
  
  deinit {
    let x = buffer.baseAddress!
    let y = x.advanced(by: offset)
    x.deinitialize(count: count)
    y.deinitialize(count: count)
    buffer.deallocate()
  }
}
