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
///   @_transparent
///   public static var fractionBits: Int { 3 }
///
///   // The only other thing we need to do is to define
///   // how we construct one from its bit pattern.
///   @_transparent
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
  
  associatedtype IntegerType: FixedWidthInteger
  
  var bitPattern: IntegerType { get set }
  
  static var fractionBits: Int { get }
  
  init(bitPattern: IntegerType)
}

extension FixedPoint {
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
  
  @_transparent
  public static var min: Self {
    Self(bitPattern: .min)
  }
  
  @_transparent
  public static var max: Self {
    Self(bitPattern: .max)
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
