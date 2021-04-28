//===--- ArithmeticCore.swift ---------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import _NumericsShims
import _StaticBuffer

extension StaticBuffer where Element == Word {
  
  /// A StaticBuffer with all elements zero.
  @_transparent
  init() {
    self.init(repeating: 0)
  }
  
  /// Full add with carry.
  ///
  /// `(result, carry-out) = a + b + carry-in`.
  ///
  /// Note that `a` and `b` need not have the same type, but `b` cannot
  /// have larger storage than `a`, because the type of the result
  /// is taken from `a`.
  ///
  /// - Parameters:
  ///   - a: The first addend.
  ///   - b: The second addend.
  ///   - carry: On input, the carry-in to the addition. On output, the
  ///            borrow-out.
  ///
  /// - Precondition: b must not have larger storage than a.
  @_transparent
  static func add<Other>(
    _ a: Self,
    _ b: Other,
    _ carry: inout Bool
  ) -> Self
  where Other: StaticBuffer, Other.Element == Word {
    assert(Other.count <= Self.count)
    var r = Self()
    for i in indices {
      r[i] = _numerics_adc(a[i], i < Other.count ? b[i] : 0, &carry)
    }
    return r
  }
  
  /// Full subtract with borrow.
  ///
  /// `(result, borrow-out) = a - b - borrow-in`.
  ///
  /// Note that `a` and `b` need not have the same type, but `b` cannot
  /// have larger storage than `a`, because the type of the result
  /// is taken from `a`.
  ///
  /// - Parameters:
  ///   - a: The subtrahend.
  ///   - b: The minuend.
  ///   - borrow: On input, the borrow-in to the subtraction. On
  ///             return, the borrow-out.
  ///
  /// - Precondition: b must not have larger storage than a.
  @_transparent
  static func sub<Other>(
    _ a: Self,
    _ b: Other,
    _ borrow: inout Bool
  ) -> Self
  where Other: StaticBuffer, Other.Element == Word {
    assert(Other.count <= Self.count)
    var r = Self()
    for i in indices {
      r[i] = _numerics_sbb(a[i], i < Other.count ? b[i] : 0, &borrow)
    }
    return r
  }
}

extension StaticBuffer where Element == Word {
  /// Add without carry-in or carry-out.
  ///
  /// Use this when you do not need the carry, or you know that no carry
  /// can occur. Mainly useful as an implementation detail for multiply.
  /// Note that `a` and `b` need not have the same type, but `b` cannot
  /// have larger storage than `a`, because the type of the result
  /// is taken from `a`.
  ///
  /// - Parameters:
  ///   - a: The first addend.
  ///   - b: The second addend.
  ///
  /// - Precondition: b must not have larger storage than a.
  @_transparent
  static func add<Other>(_ a: Self, _ b: Other) -> Self
  where Other: StaticBuffer, Other.Element == Word {
    var carry = false
    let r = add(a, b, &carry)
    return r
  }
  
  /// Subtract without borrow-in or borrow-out.
  ///
  /// Use this when you do not need the borrow, or you know that no borrow
  /// can occur. Note that `a` and `b` need not have the same type, but `b`
  /// cannot have larger storage than `a`, because the type of the result
  /// is taken from `a`.
  ///
  /// - Parameters:
  ///   - a: The subtrahend.
  ///   - b: The minuend.
  ///
  /// - Precondition: b must not have larger storage than a.
  @_transparent
  static func sub<Other>(_ a: Self, _ b: Other) -> Self
  where Other: StaticBuffer, Other.Element == Word {
    var borrow = false
    let r = sub(a, b, &borrow)
    return r
  }
}

extension Word: StaticBuffer {
  
  public typealias Element = Word
  
  @_transparent
  public init(repeating element: Word) {
    self = element
  }
}

extension Wordx2: StaticBuffer {
  
  public typealias Element = Word
  
  @_transparent
  public init(repeating element: Word) {
    self.init(_storage: (
      element, element
    ))
  }
}

extension Wordx4: StaticBuffer {
  
  public typealias Element = Word
  
  @_transparent
  public init(repeating element: Word) {
    self.init(_storage: (
      element, element, element, element
    ))
  }
}

extension Wordx8: StaticBuffer {
  
  public typealias Element = Word
  
  @_transparent
  public init(repeating element: Word) {
    self.init(_storage: (
      element, element, element, element,
      element, element, element, element
    ))
  }
}
