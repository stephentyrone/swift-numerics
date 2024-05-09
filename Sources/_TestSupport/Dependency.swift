//===--- Dependency.swift -------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import _NumericsShims

#if arch(arm64)
// These functions take advantage of the fact that CPU implementations
// generally do not track sub-register FP/SIMD dependencies. Because scalar
// floating-point values are kept only in the low-order parts of SIMD
// registers, we can copy other into the high-order part, introducing a
// dependency from the core's perspective without modifying the value.
//
// It is _possible_ to build a core that tracks dependencies at finer
// granularity, which could break this method of measurement. It would also
// be possible for a compiler to defeat this mechanism by doing analysis
// of the inline assembly that we use, but both of these are fairly unlikely.

/// Returns `self`, but attempts to insert a microarchitectural dependency on
/// `other` for the purposes of measuring latency.
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
extension Float16 {
  @_transparent
  public func insertDependency(on other: Float16) -> Float16 {
    _numerics_false_dependency_f16(self, other)
  }
}
#endif

#if arch(arm64) || arch(x86_64)
extension Float {
  @_transparent
  public func insertDependency(on other: Float) -> Float {
    _numerics_false_dependency_f32(self, other)
  }
}

extension Double {
  @_transparent
  public func insertDependency(on other: Double) -> Double {
    _numerics_false_dependency_f64(self, other)
  }
}
#endif
