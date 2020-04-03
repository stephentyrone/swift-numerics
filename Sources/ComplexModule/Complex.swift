//===--- Complex.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import RealModule

/// A complex number represented by real and imaginary parts.
///
/// See [Complex Number](https://en.wikipedia.org/wiki/Complex_number).
///
/// Representation:
/// -
/// A `Complex` value is stored as two `RealType` values, which represent
/// the real and imaginary parts of the complex number. The memory layout
/// of `Complex` is compatible with C `_Complex` types, and with C++
/// `std::complex` types.
///
/// Zero and Infinity:
/// -
/// Unlike C and C++, `Complex` does not attempt to make a semantic
/// distinction between different infinity and NaN values. Any `Complex`
/// datum with a non-finite component is treated as the "point at infinity"
/// on the Riemann sphere--a value with infinite magnitude and unspecified
/// phase.
///
/// As a consequence, all values with either component infinite or NaN
/// compare equal, and hash the same.
///
/// Similarly, all zero values compare equal and hash the same.
///
/// Mixed real/complex arithmetic:
/// -
/// Because the real numbers are a subset of the complex numbers, many
/// languages support arithmetic with mixed real and complex operands.
/// For example, C allows the following:
/// ```c
///
/// #include <complex.h>
/// double r = 1;
/// double complex z = CMPLX(0, 2); // 2i
/// double complex w = r + z;       // 1 + 2i
/// ```
///
/// This type does not provide mixed operators.
/// There are two reasons for this choice.
/// First, Swift generally avoids mixed-type arithmetic when the operation can
/// be adequately expressed with conversion.
/// Second, under the existing typechecker behavior, mixed-type arithmetic
/// would lead to highly undesirable behavior in common expressions (see
/// Arithmetic.md for further details).
///
/// To write the example above in Swift, an explicit conversion is needed:
/// ```swift
/// import ComplexModule
/// let r = 1.0
/// let z = Complex<Double>(0, 2)
/// let w = Complex(r) + z
/// ```
///
/// There are a few "loopholes" that you can use, however.
/// - Complex conforms to `Numeric`, and is therefore also
///   `ExpressibleByIntegerLiteral`. Thus, integer literals can be used
///   freely in expressions:
///   ```
///   let w = 1 + z
///   ```
/// -
///
///
@frozen
public struct Complex<RealType> where RealType: Real {
  //  A note on the `x` and `y` properties
  //
  //  `x` and `y` are the names we use for the raw storage of the real and
  //  imaginary components of our complex number. We also provide public
  //  `.real` and `.imaginary` properties, which wrap this storage and
  //  fixup the semantics for non-finite values.
  
  /// The real component of the value.
  @usableFromInline @inline(__always)
  internal var x: RealType
  
  /// The imaginary part of the value.
  @usableFromInline @inline(__always)
  internal var y: RealType
  
  /// A complex number constructed by specifying the real and imaginary parts.
  @_transparent
  public init(_ real: RealType, _ imaginary: RealType) {
    x = real
    y = imaginary
  }
}

// MARK: - Basic properties
extension Complex {
  /// The real part of this complex value.
  ///
  /// If `z` is not finite, `z.real` is `.nan`.
  public var real: RealType {
    @_transparent
    get { isFinite ? x : .nan }

    @_transparent
    set { x = newValue }
  }
  
  /// The imaginary part of this complex value.
  ///
  /// If `z` is not finite, `z.imaginary` is `.nan`.
  public var imaginary: RealType {
    @_transparent
    get { isFinite ? y : .nan }

    @_transparent
    set { y = newValue }
  }
  
  /// The additive identity, with real and imaginary parts both zero.
  ///
  /// See also:
  /// -
  /// - .one
  /// - .i
  /// - .infinity
  @_transparent
  public static var zero: Complex {
    Complex(0, 0)
  }
  
  /// The multiplicative identity, with real part one and imaginary part zero.
  ///
  /// See also:
  /// -
  /// - .zero
  /// - .i
  /// - .infinity
  @_transparent
  public static var one: Complex {
    Complex(1, 0)
  }
  
  /// The imaginary unit.
  ///
  /// See also:
  /// -
  /// - .zero
  /// - .one
  /// - .infinity
  @_transparent
  public static var i: Complex {
    Complex(0, 1)
  }
  
  /// The point at infinity.
  ///
  /// See also:
  /// -
  /// - .zero
  /// - .one
  /// - .i
  @_transparent
  public static var infinity: Complex {
    Complex(.infinity, 0)
  }
  
  /// The complex conjugate of this value.
  @_transparent
  public var conjugate: Complex {
    Complex(x, -y)
  }
  
  /// True if this value is finite.
  ///
  /// A complex value is finite if neither component is an infinity or nan.
  ///
  /// See also:
  /// -
  /// - `.isNormal`
  /// - `.isSubnormal`
  /// - `.isZero`
  @_transparent
  public var isFinite: Bool {
    x.isFinite && y.isFinite
  }
  
  /// True if this value is normal.
  ///
  /// A complex number is normal if it is finite and *either* the real or imaginary component is normal.
  /// A floating-point number representing one of the components is normal if its exponent allows a full-
  /// precision representation.
  ///
  /// See also:
  /// -
  /// - `.isFinite`
  /// - `.isSubnormal`
  /// - `.isZero`
  @_transparent
  public var isNormal: Bool {
    isFinite && (x.isNormal || y.isNormal)
  }
  
  /// True if this value is subnormal.
  ///
  /// A complex number is subnormal if it is finite, not normal, and not zero. When the result of a
  /// computation is subnormal, underflow has occurred and the result generally does not have full
  /// precision.
  /// See also:
  /// -
  /// - `.isFinite`
  /// - `.isNormal`
  /// - `.isZero`
  @_transparent
  public var isSubnormal: Bool {
    isFinite && !isNormal && !isZero
  }
  
  /// True if this value is zero.
  ///
  /// A complex number is zero if *both* the real and imaginary components are zero.
  ///
  /// See also:
  /// -
  /// - `.isFinite`
  /// - `.isNormal`
  /// - `.isSubnormal`
  @_transparent
  public var isZero: Bool {
    x == 0 && y == 0
  }
  
  /// A "canonical" representation of the value.
  ///
  /// For normal complex numbers with a RealType conforming to
  /// BinaryFloatingPoint (the common case), the result is simply this value
  /// unmodified. For zeros, the result has the representation (+0, +0). For
  /// infinite values, the result has the representation (+inf, +0).
  ///
  /// If the RealType admits non-canonical representations, the x and y
  /// components are canonicalized in the result.
  ///
  /// This is mainly useful for interoperation with other languages, where
  /// you may want to reduce each equivalence class to a single representative
  /// before passing across language boundaries, but it may also be useful
  /// for some serialization tasks. It's also a useful implementation detail for
  /// some primitive operations.
  @_transparent
  public var canonicalized: Self {
    if isZero { return .zero }
    if isFinite { return self.multiplied(by: 1) }
    return .infinity
  }
}

// MARK: - Additional Initializers
extension Complex {
  /// The complex number with specified real part and zero imaginary part.
  ///
  /// Equivalent to `Complex(real, 0)`.
  @inlinable
  public init(_ real: RealType) {
    self.init(real, 0)
  }
  
  /// The complex number with specified imaginary part and zero real part.
  ///
  /// Equivalent to `Complex(0, imaginary)`.
  @inlinable
  public init(imaginary: RealType) {
    self.init(0, imaginary)
  }
  
  /// The complex number with specified real part and zero imaginary part.
  ///
  /// Equivalent to `Complex(RealType(real), 0)`.
  @inlinable
  public init<Other: BinaryInteger>(_ real: Other) {
    self.init(RealType(real), 0)
  }
  
  /// The complex number with specified real part and zero imaginary part,
  /// if it can be constructed without rounding.
  @inlinable
  public init?<Other: BinaryInteger>(exactly real: Other) {
    guard let real = RealType(exactly: real) else { return nil }
    self.init(real, 0)
  }
  
  public typealias IntegerLiteralType = Int
  
  @inlinable
  public init(integerLiteral value: Int) {
    self.init(RealType(value))
  }
}

extension Complex where RealType: BinaryFloatingPoint {
  /// `other` rounded to the nearest representable value of this type.
  @inlinable
  public init<Other: BinaryFloatingPoint>(_ other: Complex<Other>) {
    self.init(RealType(other.x), RealType(other.y))
  }
  
  /// `other`, if it can be represented exactly in this type; otherwise `nil`.
  @inlinable
  public init?<Other: BinaryFloatingPoint>(exactly other: Complex<Other>) {
    guard let x = RealType(exactly: other.x),
          let y = RealType(exactly: other.y) else { return nil }
    self.init(x, y)
  }
}

// MARK: - Conformance to Hashable and Equatable
//
// The Complex type identifies all non-finite points (waving hands slightly,
// we identify all NaNs and infinites as the point at infinity on the Riemann
// sphere).
extension Complex: Hashable {
  @_transparent
  public static func ==(a: Complex, b: Complex) -> Bool {
    // Identify all numbers with either component non-finite as a single
    // "point at infinity".
    guard a.isFinite || b.isFinite else { return true }
    // For finite numbers, equality is defined componentwise. Cases where
    // only one of a or b is infinite fall through to here as well, but this
    // expression correctly returns false for them so we don't need to handle
    // them explicitly.
    return a.x == b.x && a.y == b.y
  }
  
  @_transparent
  public func hash(into hasher: inout Hasher) {
    // There are two equivalence classes to which we owe special attention:
    // All zeros should hash to the same value, regardless of sign, and all
    // non-finite numbers should hash to the same value, regardless of
    // representation. The correct behavior for zero falls out for free from
    // the hash behavior of floating-point, but we need to use a
    // representative member for any non-finite values.
    if isFinite {
      hasher.combine(x)
      hasher.combine(y)
    } else {
      hasher.combine(RealType.infinity)
    }
  }
}

// MARK: - Conformance to Codable
// FloatingPoint does not refine Codable, so this is a conditional conformance.
extension Complex: Decodable where RealType: Decodable {
  public init(from decoder: Decoder) throws {
    var unkeyedContainer = try decoder.unkeyedContainer()
    let x = try unkeyedContainer.decode(RealType.self)
    let y = try unkeyedContainer.decode(RealType.self)
    self.init(x, y)
  }
}

extension Complex: Encodable where RealType: Encodable {
  public func encode(to encoder: Encoder) throws {
    var unkeyedContainer = encoder.unkeyedContainer()
    try unkeyedContainer.encode(x)
    try unkeyedContainer.encode(y)
  }
}

// MARK: - Formatting
extension Complex: CustomStringConvertible {
  public var description: String {
    guard isFinite else {
      return "inf"
    }
    return "(\(x), \(y))"
  }
}

extension Complex: CustomDebugStringConvertible {
  public var debugDescription: String {
    "Complex<\(RealType.self)>(\(String(reflecting: x)), \(String(reflecting: y)))"
  }
}

