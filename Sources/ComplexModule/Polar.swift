//===--- Polar.swift ------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// API for working with polar representations of complex numbers
//
// Policies:
// - zero and non-finite numbers have indeterminate phase. Thus, the `phase`
//   property of `.zero` or `.infinity` is `RealType.nan`.

extension Complex {
  /// The phase (angle, or "argument").
  ///
  /// Returns the angle (measured above the real axis) in radians. If
  /// the complex value is zero or infinity, the phase is not defined,
  /// and `nan` is returned.
  ///
  /// Edge cases:
  /// -
  /// If the complex value is zero or non-finite, phase is `nan`.
  ///
  /// See also:
  /// -
  /// - `.length`
  /// - `.polar`
  /// - `init(r:θ:)`
  @inlinable
  public var phase: RealType {
    guard isFinite && !isZero else { return .nan }
    return .atan2(y: y, x: x)
  }
  
  /// The length and phase (or polar coordinates) of this value.
  ///
  /// Edge cases:
  /// -
  /// If the complex value is zero or non-finite, phase is `.nan`.
  /// If the complex value is non-finite, length is `.infinity`.
  ///
  /// See also:
  /// -
  /// - `.length`
  /// - `.phase`
  /// - `init(r:θ:)`
  public var polar: (length: RealType, phase: RealType) {
    (length, phase)
  }
  
  /// Creates a complex value specified with polar coordinates.
  ///
  /// Edge cases:
  /// -
  /// - Negative lengths are interpreted as reflecting the point through the origin, i.e.:
  ///   ```
  ///   Complex(length: -r, phase: θ) == -Complex(length: r, phase: θ)
  ///   ```
  /// - For any `θ`, even `.infinity` or `.nan`:
  ///   ```
  ///   Complex(length: .zero, phase: θ) == .zero
  ///   ```
  /// - For any `θ`, even `.infinity` or `.nan`, if `r` is infinite then:
  ///   ```
  ///   Complex(length: r, phase: θ) == .infinity
  ///   ```
  /// - Otherwise, `θ` must be finite, or a precondition failure occurs.
  ///
  /// See also:
  /// -
  /// - `.length`
  /// - `.phase`
  /// - `.polar`
  @inlinable
  public init(length: RealType, phase: RealType) {
    if phase.isFinite {
      self = Complex(.cos(phase), .sin(phase)).multiplied(by: length)
    } else {
      precondition(
        length.isZero || length.isInfinite,
        "Either phase must be finite, or length must be zero or infinite."
      )
      self = Complex(length)
    }
  }
}
