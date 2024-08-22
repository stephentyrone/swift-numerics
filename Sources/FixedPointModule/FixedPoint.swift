//===--- FixedPoint.swift -------------------------------------*- swift -*-===//
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

/// A binary [fixed-point][fixed] arithmetic type.
///
/// A fixed-point type is represented by an integer, but we consider a _fixed_
/// subset of the bits to be fractional. For example, we might define an eight
/// bit signed type with three fractional bits. We can do this with a minimal
/// amount bit of boilerplate:
///
/// ```swift
/// @frozen struct Int8Q3: FixedPoint {
///   // An eight-bit signed type ...
///   public var bitPattern: Int8
///
///   // ... with three fractional bits
///   public static var fractionBits: Int { 3 }
///
///   // If we want, we can customize the rounding policy of the *, &*, /
///   // operators (otherwise, it defaults to .toNearestOrUp)
///   public static var defaultRounding: RoundingRule { .toNearestOrEven }
///
///   // The only other thing we need to do is to define
///   // how we construct one from its bit pattern.
///   public init(bitPattern: Int8) {
///     self.bitPattern = bitPattern
///   }
/// }
/// ```
/// `Int8` can represent integers between `-128` and `127`; because we have
/// three fractional bits, our `Int8Q3` type represents all multiples of 1/8
/// between `-16` (`-0b10000.000`) and `15.875` (`0b01111.111`).
///
/// Addition and subtraction of fixed-point numbers is just addition or
/// subtraction of the underlying bit patterns:
/// ```swift
///                          // bit pattern
/// let a: Int8Q3 = 1.125    // 0b00001.001
/// let b: Int8Q3 = 2.5      // 0b00010.100
/// let c: Int8Q3 = a + b    // 0b00011.101 (3.625)
/// ```
/// Just like integer arithmetic, addition and subtraction trap on overflow,
/// but wrapping operations are provided as `&+` and `&-`:
/// ```swift
///                          // bit pattern
/// let a: Int8Q3 = 15.125   // 0b01111.001
/// let b: Int8Q3 = 1.5      // 0b00001.100
/// let c: Int8Q3 = a + b    //   [trap]
/// let d: Int8Q3 = a &+ b   // 0b10000.101 (-15.375)
/// ```
///
/// [fixed]: https://en.wikipedia.org/wiki/Fixed-point_arithmetic
public protocol FixedPoint:
  AdditiveArithmetic,
  ExpressibleByIntegerLiteral,
  ExpressibleByFloatLiteral,
  Comparable,
  Hashable,
  LosslessStringConvertible,
  Numeric
where Magnitude: FixedPoint,
      Magnitude.IntegerType: UnsignedInteger,
      Magnitude.Magnitude == Magnitude {
  
  /// The underlying `FixedWidthInteger` type used to represent values of
  /// this type.
  ///
  /// If IntegerType is signed, then this type is signed. If IntegerType
  /// is unsigned, then this type is unsigned.
  associatedtype IntegerType: FixedWidthInteger
  
  /// The number of bits in the representation that have fractional weight.
  ///
  /// For instance, a fixed-point type capable of representing multiples of
  /// 1/8 would have `fractionBits = 3`.
  ///
  /// - Precondition: this value must be greater than zero, and less than
  ///   or equal to the number of value bits in
  ///   ``/FixedPointModule/FixedPoint/IntegerType``.
  static var fractionBits: Int { get }
  
  /// The rounding rule to use with the `*`, `&*`, and `/` operators.
  ///
  /// > Note:
  /// If you do not specify a `defaultRounding` rule when defining a
  /// FixedPoint type, it will default to `.toNearestOrUp`.
  static var defaultRounding: RoundingRule { get }
  
  /// The integer representation underlying this fixed-point value.
  ///
  /// For example, if we have a signed eight-bit fixed-point type with
  /// three fraction bits named `Int8Q3`, then:
  /// ```
  /// let fixed: Int8Q3 = 2
  /// let bits = fixed.bitPattern // 0b00010_000 = 16 as Int8
  /// ```
  var bitPattern: IntegerType { get set }
  
  /// Create a fixed-point value from an integer bitPattern.
  init(bitPattern: IntegerType)
}

extension FixedPoint {
  
  @_transparent
  public static var defaultRounding: RoundingRule {
    .toNearestOrUp
  }
  
  /// Validate the invariants on fractionBits; this is a type-level property,
  /// but we can't encode the requirements in the type system. Instead we
  /// enforce them as an assert in initializers so that they are checked
  /// (redundantly) in debug builds but should be eliminated in release.
  @usableFromInline @_transparent
  static func invariantCheck() {
    if IntegerType.isSigned {
      assert(fractionBits > 0 && fractionBits < IntegerType.bitWidth)
    } else {
      assert(fractionBits > 0 && fractionBits <= IntegerType.bitWidth)
    }
  }
  
  /// Mask to select the ones bit in `bitPattern`.
  ///
  /// If `IntegerType` is signed and `fractionBits` is `IntegerType.bitWidth-1`,
  /// then there is—strictly speaking—no ones bit and `unit` identifies the sign
  /// bit. Similarly, if `IntegerType` is unsigned and `fractionBits` is
  /// `IntegerType.bitWidth`, then there is no ones bit and `unit` is zero.
  @usableFromInline @inline(__always)
  static internal var unit: IntegerType {
    return 1 << fractionBits
  }
  
  /// Mask to select the ½ bit in `bitPattern`.
  ///
  /// Unlike `unit`, this bit always exists, and is never a signbit.
  @usableFromInline @inline(__always)
  static internal var half: IntegerType {
    return 1 << (fractionBits - 1)
  }
  
  /// Mask to select the fractional bits in `bitPattern`.
  @usableFromInline @inline(__always)
  static internal var fractionMask: IntegerType { unit &- 1 }
  
  /// Mask to select the integral bits (including sign bit) in `bitPattern`.
  @usableFromInline @inline(__always)
  static internal var integralMask: IntegerType { 0 &- unit }
  
  /// The number of bits used to represent the integeral part of the type.
  @usableFromInline @inline(__always)
  static internal var integralBits: Int { IntegerType.bitWidth - fractionBits }
  
  /// A string describing the type, e.g. "signed 26.6"
  @usableFromInline @inline(never)
  static internal var name: String {
    "\(IntegerType.isSigned ? "" : "un")signed \(integralBits).\(fractionBits)"
  }
}

extension FixedPoint {
  @_transparent
  static public func ==(a: Self, b: Self) -> Bool {
    a.bitPattern == b.bitPattern
  }
  
  @_transparent
  static public func <(a: Self, b: Self) -> Bool {
    a.bitPattern < b.bitPattern
  }
  
  @_transparent
  public func hash(into hasher: inout Hasher) {
    hasher.combine(bitPattern)
  }
  
  /// The minimum representable number in this type.
  @_transparent
  public static var min: Self {
    Self(bitPattern: .min)
  }
  
  /// The maximum representable number in this type.
  @_transparent
  public static var max: Self {
    Self(bitPattern: .max)
  }
  
  /// The least-magnitude number representable in this type.
  ///
  /// Every number is an integral multiple of this value.
  @_transparent
  public static var leastMagnitude: Self {
    Self(bitPattern: 1)
  }
  
  @_transparent @usableFromInline
  internal var integralPart: IntegerType {
    bitPattern >> Self.fractionBits
  }
  
  @_transparent @usableFromInline
  internal var fractionalPart: IntegerType {
    bitPattern & Self.fractionMask
  }
}
