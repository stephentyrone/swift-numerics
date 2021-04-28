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

public struct UInt128 {
#if arch(arm) || arch(i386)
  var _words: Wordx4
#else
  var _words: Wordx2
#endif
}

extension UInt128: Hashable {
  public static func ==(a: Self, b: Self) -> Bool {
    zip(a._words, b._words).allSatisfy(==)
  }
  
  public func hash(into hasher: inout Hasher) {
    _ = _words.reduce(into: hasher) { $0.combine($1) }
  }
}

extension UInt128: AdditiveArithmetic {
  public static var zero: UInt128 {
    Self(_words: .init())
  }
  
  public static func +(a: Self, b: Self) -> Self {
    var carry = false
    let result = Self(_words: .add(a._words, b._words, &carry))
    precondition(!carry)
    return result
  }
  
  public static func -(a: Self, b: Self) -> Self {
    var borrow = false
    let result = Self(_words: .sub(a._words, b._words, &borrow))
    precondition(!borrow)
    return result
  }
  
  public static func &+(a: Self, b: Self) -> Self {
    Self(_words: .add(a._words, b._words))
  }
  
  public static func &-(a: Self, b: Self) -> Self {
    Self(_words: .sub(a._words, b._words))
  }
}
