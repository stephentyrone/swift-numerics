//===--- Norms.swift ------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// Norms and related quantities defined for Complex.
//
// The following API are provided by this extension:
//
//   var magnitude: RealType     // infinity norm
//   var length: RealType        // Euclidean norm
//   var lengthSquared: RealType // Euclidean norm squared
//
// For detailed documentation, consult Norms.md or the inline documentation
// for each operation.
//
// Implementation notes:
//
// `.magnitude` does not bind the Euclidean norm; it binds the infinity norm
// instead. There are two reasons for this choice:
//
// - It's simply faster to compute in general, because it does not require
//   a square root.
//
// - There exist finite values z for which the Euclidean norm is not
//   representable (consider the number with `.real` and `.imaginary` both
//   equal to `RealType.greatestFiniteMagnitude`; the Euclidean norm is
//   `.sqrt(2) * .greatestFiniteMagnitude`, which overflows).
//
// The infinity norm is unique among the common vector norms in having
// the property that every finite vector has a representable finite norm,
// which makes it the obvious choice to bind `.magnitude`.
extension Complex {
  
  /// The infinity-norm of the value (a.k.a. maximum norm or Чебышёв norm).
  ///
  /// If you need to work with the Euclidean norm (a.k.a. 2-norm) specifically,
  /// use the `length` or `lengthSquared` properties. If you just need to
  /// know "how big" a number is, use this property.
  ///
  /// Edge cases:
  /// -
  /// - If `z` is not finite, `z.magnitude` is `.infinity`.
  /// - If `z` is zero, `z.magnitude` is `0`.
  /// - Otherwise, `z.magnitude` is finite and non-zero.
  ///
  /// See also:
  /// -
  /// - `.length`
  /// - `.lengthSquared`
  @_transparent
  public var magnitude: RealType {
    guard isFinite else { return .infinity }
    return max(abs(x), abs(y))
  }
  
  /// The Euclidean norm (a.k.a. 2-norm)..
  ///
  /// This property takes care to avoid spurious over- or underflow in
  /// this computation. For example:
  ///
  ///     let x: Float = 3.0e+20
  ///     let x: Float = 4.0e+20
  ///     let naive = sqrt(x*x + y*y) // +Inf
  ///     let careful = Complex(x, y).length // 5.0e+20
  ///
  /// Note that it *is* still possible for this property to overflow,
  /// because the length can be as much as sqrt(2) times larger than
  /// either component, and thus may not be representable in the real type.
  ///
  /// For most use cases, you can use the cheaper `.magnitude`
  /// property (which computes the ∞-norm) instead, which always produces
  /// a representable result.
  ///
  /// Edge cases:
  /// -
  /// If a complex value is not finite, its `.length` is `infinity`.
  ///
  /// See also:
  /// -
  /// - `.magnitude`
  /// - `.lengthSquared`
  /// - `.phase`
  /// - `.polar`
  /// - `init(r:θ:)`
  @_transparent
  public var length: RealType {
    let naive = lengthSquared
    guard naive.isNormal else { return carefulLength }
    return .sqrt(naive)
  }
  
  /// The squared length `(real*real + imaginary*imaginary)`.
  ///
  /// This property is more efficient to compute than `length`, but is
  /// highly prone to overflow or underflow; for finite values that are
  /// not well-scaled, `lengthSquared` is often either zero or
  /// infinity, even when `length` is a finite number. Use this property
  /// only when you are certain that this value is well-scaled.
  ///
  /// For many cases, `.magnitude` can be used instead, which is similarly
  /// cheap to compute and always returns a representable value.
  ///
  /// See also:
  /// -
  /// - `.length`
  /// - `.magnitude`
  @_transparent
  public var lengthSquared: RealType {
    x*x + y*y
  }
  
  //  Internal implementation detail of `length`, moving slow path off
  //  of the inline function. Note that even `carefulLength` can overflow
  //  for finite inputs, but only when the result is outside the range
  //  of representable values.
  @usableFromInline
  internal var carefulLength: RealType {
    guard isFinite else { return .infinity }
    return .hypot(x, y)
  }
}
