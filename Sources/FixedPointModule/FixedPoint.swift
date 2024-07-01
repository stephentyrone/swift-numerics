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

/// A fixed-point arithmetic type.
///
/// All of the operations that you are likely to need are defined as protocol
/// extensions. Defining your actual fixed-point types is done as follows:
/// ```swift
/// // Define your type and conform to FixedPoint. Here we are defining a
/// // 26.6 signed fixed-point type.
/// @frozen
/// struct Int26_6: FixedPoint {
///   // Define the underlying integer storage. For an unsigned fixed-point
///   // type, you would use an unsigned integer type. (Note that this
///   // definition leads to the associatedtype `IntegerType` being
///   // inferred as Int32; you could also define it explicitly if you
///   // prefer).
///   public var bitPattern: Int32
///
///   // Number of fractional bits. For a signed type, this must be between
///   // zero and bitWidth-1 (because there must be a sign bit). For an
///   // unsigned type, it can be as large as bitWidth.
///   @_transparent
///   public static var fractionBits = 6
///
///   // Provide the following hook to initialize the underlying integer value.
///   @_transparent
///   public init(bitPattern: Int32) {
///     self.bitPattern = bitPattern
///   }
/// }
/// ```
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
