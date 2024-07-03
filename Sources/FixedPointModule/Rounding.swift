//===--- Rounding.swift ---------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import IntegerUtilities

extension FixedPoint {
  @inlinable
  public func rounded(_ rule: RoundingRule = .toNearestOrEven) -> Self {
    let s = self.bitPattern
    let i = Self.integralMask
    let f = Self.fractionMask
    let u = Self.unit
    let g = s.signbit
    switch rule {
    case .down:
      return Self(bitPattern: s & i)
    case .up:
      return Self(bitPattern: (s + f) & i)
    case .towardZero:
      return Self(bitPattern: (s + (f & g)) & i)
    case .awayFromZero:
      return Self(bitPattern: (s + (f & ~g)) & i)
    case .toOdd:
      return Self(bitPattern: (s & i) | (s &+ f & u))
    case .toNearestOrAwayFromZero:
      fatalError()
    case .toNearestOrEven:
      fatalError()
    case .toNearestOrUp:
      fatalError()
    case .stochastically:
      return Self(bitPattern: (s + .random(in: 0...f)) & i)
    case .requireExact:
      precondition(s & f == 0)
      return Self(bitPattern: s & i)
    }
  }
}
