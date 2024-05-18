//===--- RealFunctions.swift ----------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

public protocol RealFunctions: ElementaryFunctions {
  /// `atan(y/x)`, with representative selected using the quadrant`(x, y)`.
  ///
  /// The [atan2 function][wiki] computes the angle (in radians) formed
  /// between the positive real axis and the point `(x, y)`. The result
  /// is in the range [-π, π], and its sign matches the sign of y.
  ///
  /// > Warning:
  /// Note the parameter ordering of this function; the `y` parameter
  /// comes *before* the `x` parameter. This is a historical curiosity
  /// going back to early FORTRAN math libraries. In order to minimize
  /// opportunities for confusion and subtle bugs, we require explicit
  /// parameter labels with this function.
  ///
  /// **See also:**
  /// ``ElementaryFunctions/acos(_:)``,
  /// ``ElementaryFunctions/asin(_:)``,
  /// ``ElementaryFunctions/atan(_:)``,
  /// ``atan2OverPi(y:x:)``
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Atan2
  static func atan2(y: Self, x: Self) -> Self
  
  /// The [error function][wiki] evaluated at `x`.
  ///
  /// See also:
  /// -
  /// - `erfc(_:)`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Error_function
  static func erf(_ x: Self) -> Self
  
  /// The complimentary [error function][wiki] evaluated at `x`.
  ///
  /// See also:
  /// -
  /// - `erf(_:)`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Error_function
  static func erfc(_ x: Self) -> Self
  
  /// 2ˣ
  ///
  /// See also:
  /// -
  /// - `ElementaryFunctions.exp(_:)`
  /// - `ElementaryFunctions.expMinusOne(_:)`
  /// - `exp10(_:)`
  /// - `log2(_:)`
  /// - `ElementaryFunctions.pow(_:)`
  static func exp2(_ x: Self) -> Self
  
  /// 10ˣ
  ///
  /// See also:
  /// -
  /// - `ElementaryFunctions.exp(_:)`
  /// - `ElementaryFunctions.expMinusOne(_:)`
  /// - `exp2(_:)`
  /// - `log10(_:)`
  /// - `ElementaryFunctions.pow(_:)`
  static func exp10(_ x: Self) -> Self
  
  /// The square root of the sum of squares of `x` and `y`.
  ///
  /// The naive expression `.sqrt(x*x + y*y)` and overflow
  /// or underflow if `x` or `y` is not well-scaled, producing zero or
  /// infinity, even when the mathematical result is representable.
  ///
  /// The [hypot][wiki] takes care to avoid this, and always
  /// produces an accurate result when one is available.
  ///
  /// See also:
  /// -
  /// - `ElementaryFunctions.sqrt(_:)`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Hypot
  static func hypot(_ x: Self, _ y: Self) -> Self
  
  /// The [gamma function][wiki] Γ(x).
  ///
  /// See also:
  /// -
  /// - `logGamma(_:)`
  /// - `signGamma(_:)`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Gamma_function
  static func gamma(_ x: Self) -> Self
  
  /// The base-2 logarithm of `x`.
  ///
  /// See also:
  /// -
  /// - `exp2(_:)`
  /// - `ElementaryFunctions.log(_:)`
  /// - `ElementaryFunctions.log(onePlus:)`
  /// - `log10(_:)`
  static func log2(_ x: Self) -> Self
  
  /// The base-10 logarithm of `x`.
  ///
  /// See also:
  /// -
  /// - `exp10(_:)`
  /// - `ElementaryFunctions.log(_:)`
  /// - `ElementaryFunctions.log(onePlus:)`
  /// - `log2(_:)`
  static func log10(_ x: Self) -> Self
  
#if !os(Windows)
  /// The logarithm of the absolute value of the gamma function, log(|Γ(x)|).
  ///
  /// Not available on Windows targets.
  ///
  /// See also `gamma()` and `signGamma()`.
  static func logGamma(_ x: Self) -> Self
  
  /// The sign of the [gamma function][wiki], Γ(x).
  ///
  /// For `x >= 0`, `signGamma(x)` is `.plus`. For negative `x`, `signGamma(x)`
  /// is `.plus` when `x` is an integer, and otherwise it is `.minus` whenever
  /// `trunc(x)` is even, and `.plus` when `trunc(x)` is odd.
  ///
  /// This function is used together with `logGamma`, which computes the
  /// logarithm of the absolute value of Γ(x), to recover the sign information.
  ///
  /// Not available on Windows targets.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Gamma_function
  static func signGamma(_ x: Self) -> FloatingPointSign
#endif

  // MARK: Trig-π functions
  
  /// The [arccosine][wiki] (inverse cosine) of `x`, scaled by 1/π.
  ///
  /// If `x.magnitude <= 1`, the result is the angle (in half-turns) formed
  /// between the positive real axis and the vector `(x, √(1-x²))`. This is
  /// the value `y` in `-0.5...0.5` such that ``cos(piTimes: y)`` is `x` up
  /// to floating-point rounding.
  ///
  /// **Exact values and edge cases:**
  /// - If x is not in `-1...1`, then `acosOverPi(x)` is NaN.
  /// - If x is -1, then `acosOverPi(x)` is `1.0`.
  /// - If x is ±0, then `acosOverPi(x)` is `0.5`.
  /// - If x is +1, then `acosOverPi(x)` is `0.0`.
  ///
  /// **See also:**
  /// - Other inverse-trig functions scaled by π:
  ///   ``asinOverPi(_:)``, ``atanOverPi(_:)``, ``atan2OverPi(y:x:)``
  /// - Trig functions scaled by π:
  ///   ``cos(piTimes:)``, ``sin(piTimes:)``, ``tan(piTimes:)``
  /// - Unscaled inverse trig functions, returning results in radians:
  ///   ``ElementaryFunctions/acos(_:)``,
  ///   ``ElementaryFunctions/asin(_:)``,
  ///   ``ElementaryFunctions/atan(_:)``,
  ///   ``atan2(y:x:)``
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_trigonometric_functions
  static func acosOverPi(_ x: Self) -> Self
  
  /// The [arcsine][wiki]  (inverse sine) of `x`, scaled by 1/π.
  ///
  /// If `x.magnitude <= 1`, the result is the angle (in half-turns) formed
  /// between the positive real axis and the vector `(√(1-x²), x)`. This is
  /// the value `y` in `-0.5...0.5` such that ``sin(piTimes: y)`` is `x` up
  /// to floating-point rounding.
  ///
  /// **Symmetry:**
  /// arcsine is an odd function. Thus `asinOverPi(-x)` is the same as
  /// `-asinOverPi(x)`.
  ///
  /// **Exact values and edge cases:**
  /// - If x is not in `-1...1`, then `asinOverPi(x)` is NaN.
  /// - If x is ±1, then `asinOverPi(x)` is `±0.5`.
  /// - If x is ±0, then `asinOverPi(x)` is x.
  ///
  /// **See also:**
  /// - Other inverse-trig functions scaled by π:
  ///   ``acosOverPi(_:)``, ``atanOverPi(_:)``, ``atan2OverPi(y:x:)``
  /// - Trig functions scaled by π:
  ///   ``cos(piTimes:)``, ``sin(piTimes:)``, ``tan(piTimes:)``
  /// - Unscaled inverse trig functions, returning results in radians:
  ///   ``ElementaryFunctions/acos(_:)``,
  ///   ``ElementaryFunctions/asin(_:)``,
  ///   ``ElementaryFunctions/atan(_:)``,
  ///   ``atan2(y:x:)``
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_trigonometric_functions
  static func asinOverPi(_ x: Self) -> Self
  
  /// `atan(y/x)/π`, with representative selected based on the quadrant
  /// of `(x,y)`.
  ///
  /// The [atan2OverPi function][wiki] computes the angle (in half-turns,
  /// in the range [-1, 1]) formed between the positive real axis and the
  /// point `(x,y)`. The sign of the result always matches the sign of y.
  ///
  /// > Warning:
  /// Note the parameter ordering of this function; the `y` parameter
  /// comes *before* the `x` parameter. This is a historical curiosity
  /// going back to early FORTRAN math libraries (the ordering makes
  /// some sense because atan2(y, x) computes atan(y / x) in the first
  /// and fourth quadrants). In order to minimize opportunities for
  /// confusion and subtle bugs, we require explicit parameter labels
  /// with this function.
  ///
  /// **See Also:**
  /// - Other inverse-trig functions scaled by π:
  ///   ``acosOverPi(_:)``, ``asinOverPi(_:)``, ``atanOverPi(_:)``
  /// - Trig functions scaled by π:
  ///   ``cos(piTimes:)``, ``sin(piTimes:)``, ``tan(piTimes:)``
  /// - Unscaled inverse trig functions, returning results in radians:
  ///   ``ElementaryFunctions/acos(_:)``,
  ///   ``ElementaryFunctions/asin(_:)``,
  ///   ``ElementaryFunctions/atan(_:)``,
  ///   ``atan2(y:x:)``
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Atan2
  static func atan2OverPi(y: Self, x: Self) -> Self
  
  /// The [arctangent][wiki]  (inverse tangent) of `x`, scaled by 1/π.
  ///
  /// The angle (in half-turns) formed between the positive real axis
  /// and the point `(1, x)`. This is the value `y` in `-0.5...0.5`
  /// such that ``tan(piTimes: y)`` is `x` up to floating-point rounding.
  ///
  /// **Symmetry:**
  /// arctangent is an odd function. Thus `atanOverPi(-x)` is the same as
  /// `-atanOverPi(x)`.
  ///
  /// **Exact values and edge cases:**
  /// - If x is NaN, then `atanOverPi(x)` is NaN.
  /// - If x is ±infinty, then `atanOverPi(x)` is `±0.5`.
  /// - If x is ±1, then `atanOverPi(x)` is `±0.25`.
  /// - If x is ±0, then `atanOverPi(x)` is x.
  ///
  /// **See Also:**
  /// - Other inverse-trig functions scaled by π:
  ///   ``acosOverPi(_:)``, ``asinOverPi(_:)``, ``atan2OverPi(y:x:)``
  /// - Trig functions scaled by π:
  ///   ``cos(piTimes:)``, ``sin(piTimes:)``, ``tan(piTimes:)``
  /// - Unscaled inverse trig functions, returning results in radians:
  ///   ``ElementaryFunctions/acos(_:)``,
  ///   ``ElementaryFunctions/asin(_:)``,
  ///   ``ElementaryFunctions/atan(_:)``,
  ///   ``atan2(y:x:)``
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_trigonometric_functions
  static func atanOverPi(_ x: Self) -> Self
  
  /// The [cosine][wiki] of π times `x`.
  ///
  /// Because π is not representable in any `FloatingPoint` type, for large
  /// `x`, `.cos(.pi * x)` can have arbitrarily large relative error;
  /// `.cos(piTimes: x)` always provides a result with small relative error.
  ///
  /// This is observable even for modest arguments; consider `0.5`:
  /// ```swift
  /// Float.cos(.pi * 0.5)    // 7.54979e-08
  /// Float.cos(piTimes: 0.5) // 0.0
  /// ```
  /// It's important to be clear that there is no bug in the example
  /// given above. Every step of both computations is producing the most
  /// accurate possible result.
  ///
  /// **Symmetry:**
  /// cosine is an even function. Thus for every finite `x`,
  /// ```swift
  /// .cos(piTimes: -x) == .cos(piTimes: x)
  /// ```
  ///
  /// **Exact values and edge cases:**
  /// - If x is not finite, `cos(piTimes: x)` is NaN.
  /// - If x is an even integer, `cos(piTimes: x)` is 1.
  ///   > Note:
  ///     _All_ finite values with magnitude greater than or equal to
  ///     `(radix/ulpOfOne)` are even integers.
  ///     E.g. `Double.radix` is 2, and `Double.ulpOfOne` is 2⁻⁵², so
  ///     for every `Double` x with `x.magnitude` >= 2⁵³, `cos(piTimes: x)`
  ///     is 1.
  /// - If x is an odd integer, `cos(piTimes: x)` is -1.
  /// - If x is a half-integer (i.e. x = n + ½ for some integer n),
  ///   then `cos(piTimes: x)` is +0.
  ///
  /// **See also:**
  /// - Other trig functions scaled by π:
  ///   ``sin(piTimes:)``, ``tan(piTimes:)``
  /// - Inverse-trig functions scaled by π:
  ///   ``acosOverPi(_:)``, ``asinOverPi(_:)``, ``atan2OverPi(y:x:)``,
  ///   ``atanOverPi(_:)``
  /// - Unscaled trig functions, taking arguments in radians:
  ///   ``ElementaryFunctions/cos(_:)``,
  ///   ``ElementaryFunctions/sin(_:)``,
  ///   ``ElementaryFunctions/tan(_:)``
  /// - `cos(x) - 1` (aka negative versine):
  ///   ``Real/cosMinusOne(_:)`` 
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Sine_and_cosine
  static func cos(piTimes x: Self) -> Self
  
  /// The [sine][wiki] of π times `x`.
  ///
  /// Because π is not representable in any `FloatingPoint` type, for large
  /// `x`, `.sin(.pi * x)` can have arbitrarily large relative error;
  /// `.sin(piTimes: x)` always provides a result with small relative error.
  ///
  /// This is observable even for modest arguments; consider `10`:
  /// ```swift
  /// Float.sin(.pi * 10)    // -2.4636322e-06
  /// Float.sin(piTimes: 10) // 0.0
  /// ```
  /// It's important to be clear that there is no bug in the example
  /// given above. Every step of both computations is producing the most
  /// accurate possible result.
  ///
  /// **Symmetry:**
  /// sine is an odd function. Thus for every finite `x`,
  /// ```swift
  /// .sin(piTimes: -x) == -.sin(piTimes: x)
  /// ```
  ///
  /// **Exact values and edge cases:**
  /// - If x is not finite, `sin(piTimes: x)` is NaN.
  /// - If x is an integer, `sin(piTimes: x)` is zero, with the same sign
  ///   as x (so that the function is odd).
  ///   > Note:
  ///     _All_ finite values with magnitude greater than or equal to
  ///     `(1/.ulpOfOne)` are integers.
  ///     E.g. `Double.ulpOfOne` is 2⁻⁵², so for every `Double` x with
  ///     `x.magnitude` >= 2⁵², `sin(piTimes: x)` is zero.
  /// - If x is a half-integer (i.e. x = n + ½ for some integer n),
  ///   then `sin(piTimes: x)` is 1 if n is even and -1 if n is odd.
  ///
  /// **See also:**
  /// - Other trig functions scaled by π:
  ///   ``cos(piTimes:)``, ``tan(piTimes:)``
  /// - Inverse-trig functions scaled by π:
  ///   ``acosOverPi(_:)``, ``asinOverPi(_:)``, ``atan2OverPi(y:x:)``,
  ///   ``atanOverPi(_:)``
  /// - Unscaled trig functions, taking arguments in radians:
  ///   ``ElementaryFunctions/cos(_:)``,
  ///   ``ElementaryFunctions/sin(_:)``,
  ///   ``ElementaryFunctions/tan(_:)``
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Sine_and_cosine
  static func sin(piTimes x: Self) -> Self
  
  /// The [tangent][wiki] of π times `x`.
  ///
  /// Because π is not representable in any `FloatingPoint` type, for
  /// large `x`, `.tan(.pi * x)` can have arbitrarily large relative
  /// error; `.tan(piTimes: x)` always provides a result with small
  /// relative error.
  ///
  /// This is observable even for modest arguments; consider `0.5`:
  /// ```swift
  /// Float.tan(.pi * 0.5)    // 13245402.0
  /// Float.tan(piTimes: 0.5) // infinity
  /// ```
  /// It's important to be clear that there is no bug in either example
  /// given above. Every step of both computations is producing the most
  /// accurate possible result.
  ///
  /// **Symmetry:**
  /// tangent is an odd function. Thus for every finite `x`,
  /// ```swift
  /// .tan(piTimes: -x) == -.tan(piTimes: x)
  /// ```
  ///
  /// **Exact values and edge cases:**
  /// - If x is not finite, `tan(piTimes: x)` is NaN.
  /// - If x is an integer, `tan(piTimes: x)` is zero, with the sign given
  ///   by `sin(piTimes: x)/cos(piTimes: x)`.
  /// - If x is a half-integer, `tan(piTimes: x)` is infinity, with the sign
  ///   given by `sin(piTimes: x)/cos(piTimes: x)`
  ///
  ///   Thus, if `n` is a positive even integral value and `n.ulp <= 0.5`:
  ///   - `tan(piTimes: n)` is +0/+1 = +0
  ///   - `tan(piTimes: n + 0.5)` is +1/+0 = +infinity
  ///   - `tan(piTimes: n + 1.0)` is +0/-1 = -0
  ///   - `tan(piTimes: n + 1.5)` is -1/+0 = -infinity
  ///
  ///   This means that `tan(piTimes:)` is 2-periodic, even though the
  ///   mathematical tangent function is π-periodic (not 2π).
  ///
  ///   > Note:
  ///     _All_ finite values with magnitude greater than or equal to
  ///     `(2/.ulpOfOne)` are even integers.
  ///     E.g. `Double.ulpOfOne` is 2⁻⁵², so for every `Double` x with
  ///     `x.magnitude` >= 2⁵³, `tan(piTimes: x)` is ±0.
  ///
  /// **See also:**
  /// - Other trig functions scaled by π:
  ///   ``cos(piTimes:)``, ``sin(piTimes:)``
  /// - Inverse-trig functions scaled by π:
  ///   ``acosOverPi(_:)``, ``asinOverPi(_:)``, ``atan2OverPi(y:x:)``,
  ///   ``atanOverPi(_:)``
  /// - Unscaled trig functions, taking arguments in radians:
  ///   ``ElementaryFunctions/cos(_:)``,
  ///   ``ElementaryFunctions/sin(_:)``,
  ///   ``ElementaryFunctions/tan(_:)``
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Trigonometric_functions
  static func tan(piTimes x: Self) -> Self
}

