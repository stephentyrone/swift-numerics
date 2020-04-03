# Complex Numbers

This module provides a `Complex` number type generic over an underlying `RealType`:
```swift
1> import ComplexModule
2> let z = Complex(1,1) // z = 1 + i
```
This module provides approximate feature parity and memory layout compatibility with C, Fortran, and C++ complex types (although the importer cannot map the types for you, buffers may be reinterpreted to shim API defined in other languages).

The usual arithmetic operators are provided for Complex numbers, as well as conversion to and from polar coordinates and many useful properties, plus conformances to the obvious usual protocols: `Equatable`, `Hashable`, `Codable` (if the underlying `RealType` is), and `AlgebraicField` (hence also `AdditiveArithmetic` and `SignedNumeric`).

### Dependencies:
- `RealModule`.

## Design notes

### Mixed real-complex arithmetic.
It is tempting to define real-complex arithmetic operators, because we use them as shorthand all the time in mathematics: `z + x` or `2w`.
They are not provided by the Complex module for two reasons:
- Swift generally avoids heterogenous arithmetic operators
- They lead to counter-intuitive behavior of type inference.
  For a concrete example of the second point, suppose that heterogeneous arithmetic operators existed, and consider the following snippet:
  ```swift
  let a: RealType = 1
  let b = 2*a
  ```
  what is the type of `b`?

  If there is no type context, `b` is ambiguous; `2*a` could be interpreted as `Complex(2)*a` or as `RealType(2)*a`.
  That's annoying on its own. However, suppose that we're in a `Complex` type context:
  ```swift
  extension Complex {
    static func doSomething() {
      let a: RealType = 1
      let b = 2*a // type is inferred as Complex 🤪
    }
  }
  ```
  This is a show-stopper for heterogeneous arithmetic operators in the short term.

### Infinity and nan
C and C++ attempt to define precise semantics that interpret the sign of infinity and zero.
This is occasionally useful, but it also results in a lot of extra work.
The Swift Numerics `Complex` type does not assign any semantic meaning to the sign of zero and infinity; `(±0,±0)`, are all considered to be encodings of the value zero.
Similarly, `(±inf, y)`, `(x, ±inf)`, `(nan, y)` and `(x, nan)` are all considered to be encodings of a single exceptional value with infinite magnitude and undefined phase.

Because the phase is undefined, the `real` and `imaginary` properties return `.nan` for non-finite values.
This decision might be revisited once users gain some experience working with the type to make sure that it's a tradeoff that we're happy with, but early experiments show that it greatly simplifies the implementation of some operations without significant tradeoffs in usability.

### The magnitude property
The `Numeric` protocol requires a `.magnitude` property, but (deliberately) does not fully specify the semantics.
The most obvious choice for `Complex` would be to use the Euclidean norm (aka the "2-norm", given by `sqrt(real*real + imaginary*imaginary)`).
However, in practice there are good reasons to use something else instead; we bind `.magnitude` to the infinity norm.
For discussion of this choice, as well as background information on norms, consult [Norms.md](Norms.md).

The Euclidean norm is available as the `.length` property.

### Accuracy of division and multiplication
This library attempts to provide robust division and multiplication operations, with small relative error in a complex norm. It is a non-goal to deliver small componentwise errors.
See `testBaudinSmith` in `ComplexTests.swift` for examples of cases where we have tiny relative error but large error in one of the result components considered in isolation.
This is the right tradeoff for a general-purpose library because it allows us to use the naive formulas for multiplication and division (which are fast), and do a simple check to see if we need to re-do the computation more carefully to avoid spurious overflow or underflow.
It's also about as accurate as multiplication.

Implementing the method of Baudin and Smith (or any other method that delivers similarly small componentwise error) would unduly slow down the common case for relatively little benefit--componentwise error bounds are rarely necessary when working over the complex numbers.

That said, a PR that implements multiplication and division *functions* with tight componentwise error bounds would be a welcome addition to the library.
