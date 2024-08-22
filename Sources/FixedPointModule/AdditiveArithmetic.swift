//===--- AdditiveArithmetic.swift -----------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension FixedPoint {
  @_transparent
  public static var zero: Self {
    Self(bitPattern: .zero)
  }
  
  @_transparent
  public static func +(a: Self, b: Self) -> Self {
    Self(bitPattern: a.bitPattern + b.bitPattern)
  }
  
  @_transparent
  public static func -(a: Self, b: Self) -> Self {
    Self(bitPattern: a.bitPattern - b.bitPattern)
  }
  
  @_transparent
  public static prefix func -(a: Self) -> Self {
    zero - a
  }
}

extension FixedPoint {
  @_transparent
  public static func &+(a: Self, b: Self) -> Self {
    Self(bitPattern: a.bitPattern &+ b.bitPattern)
  }
  
  @_transparent
  public static func &-(a: Self, b: Self) -> Self {
    Self(bitPattern: a.bitPattern &- b.bitPattern)
  }
  
  @_transparent
  public static func &+=(a: inout Self, b: Self) {
    a.bitPattern &+= b.bitPattern
  }
  
  @_transparent
  public static func &-=(a: inout Self, b: Self) {
    a.bitPattern &-= b.bitPattern
  }
}

/// The [absolute value](https://en.wikipedia.org/wiki/Absolute_value)
/// of this number.
///
/// > Note:
/// > If the type is signed and the argument is `.min`, then the absolute
/// > value is not representable, and a precondition failure will occur.
/// >
/// > To avoid this, you may want to use the `.magnitude` property instead,
/// > which is always representable.
/// >
/// > You could also consider using ``absWithSaturation(_:)``, which returns
/// > `.max` if the absolute value would overflow.
@_transparent
public func abs<T: FixedPoint>(_ a: T) -> T {
  a.bitPattern < .zero ? -a : a
}

/// The [absolute value](https://en.wikipedia.org/wiki/Absolute_value)
/// of this number if it is representable, otherwise `.max`.
///
/// If the type is signed and the argument is `.min`, then ``abs(_:)`` is
/// not representable and a precondition failure occurs.
///
/// The `absWithSaturation(_:)` function avoids this by saturating to `.max`
/// instead of overflowing. You might also consider using the `.magnitude`
/// property, which is always representable.
@inlinable
public func absWithSaturation<T: FixedPoint>(_ a: T) -> T {
  a.bitPattern < 0 ? .zero.subtractingWithSaturation(a) : a
}
