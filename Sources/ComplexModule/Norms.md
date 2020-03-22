# Complex Norms
In mathematics, a *norm* is a function that gives each element of a vector space a non-negative length¹.

> (1) Throughout this document, "norm" will refer to a [vector norm](https://en.wikipedia.org/wiki/Norm_(mathematics)).
> To confuse the matter, there are several similar things also called "norm" in mathematics.
> The other one you are most likely to run into is a [field norm](https://en.wikipedia.org/wiki/Field_norm).
> Field norms are less common than vector norms, but the C++ `std::norm` operation implements a field norm.

Many different norms can be defined on the complex numbers, viewed as a vector space over the reals.
All of these norms satisfy some basic properties. If we use *‖z‖* to represent any norm of *z*, it must satisfy:

- *Subadditive* (a.k.a. the triangle inequalty):    
  *‖z + w‖ ≤ ‖z‖ + ‖w‖* for any two complex numbers *z* and *w*.
- *Homogeneous*  
  *‖az‖ = |a|‖z‖* for any real number *a* and complex number *z*.
- *Positive definite*  
  *‖z‖* is zero if and only if *z* is zero.

The three most commonly-used norms are:

- 1-norm ("taxicab norm")  
  *‖x + iy‖₁ = |x| + |y|*
- 2-norm ("Euclidean norm")  
  *‖x + iy‖₂ = √(x² + y²)*
- ∞-norm ("maximum norm" or "Чебышёв [Chebyshev] norm")  
  *‖x + iy‖ = max(|x|,|y|)*

These norms are all *equivalent*, meaning that they are always within a small multiple of each other.
Because of this, they can more-or-less be used interchangably in contexts where you just want to know if a number is "big" or "small".

> Excercises:  
> 1. Prove that the ∞-norm is always less than or equal to the 1- and 2-norm.  
> 2. Prove that the 2-norm is always less than or equal to √2 times the ∞-norm.  
> 3. Prove that the 1-norm is always less than or equal to 2 times the ∞-norm.  

The `Complex` type gives special names to two of these norms; `length` for the 2-norm, and `magnitude` for the ∞-norm.

## magnitude
The `Numeric` protocol requires us to choose a norm to call `magnitude`, but does not give guidance as to which one we should pick.
The most obvious choice would be the Euclidean norm; it's the one that people are most likely to be familiar with.
However, there are good reasons to make a different choice:
- The Euclidean norm requires special care to avoid spurious overflow/underflow.
  The naive expressions for the taxicab and maximum norm always give the best answer possible.
- Even when special care is used, the Euclidean and taxicab norms are not necessarily representable.
  Both can be infinite even for finite numbers.
  ```swift
  let big = Double.greatestFiniteMagnitude
  let z = Complex(big, big)
  ```
  The taxicab norm of `z` should be `big + big`, which overflows; the Euclidean norm should be `sqrt(2) * big`, which also overflows.
  By contrast, the maximum norm is always equal to the magnitude of either `real` or `imaginary`, so it is necessarily representable if `z` is finite.
- The ∞-norm is already heavily used in established computational libraries, like BLAS and LAPACK.

For these reasons, the `magnitude` property on `Complex` is the maximum norm:
```swift
Complex(2, 3).magnitude    // 3
Complex(-1, 0.5).magnitude // 1
```

## length
The `length` property on a `Complex` value is its Euclidean norm.

```swift
Complex(2, 3).length    // 3.605551275463989
Complex(-1, 0.5).length // 1.118033988749895
```

Aside from familiarity, the Euclidean norm has one important property that the maximum norm lacks:

- *Multiplicative*  
  *‖zw‖₂ = ‖z‖₂‖w‖₂* for any two complex numbers *z* and *w*.

> Exercises: 
> 1. Why isn't the maximum norm multiplicative? (Hint: Let `z = Complex(1,1)`, and consider `z*z`.)   
> 2. Why isn't the 1-norm multiplicative?

The `length` property takes special care to produce an accurate answer, even when the value is poorly-scaled.
The naive expression for `length` would be `sqrt(x*x + y*y)`, but this can overflow or underflow even when the final result should be a finite number.
```swift
// Suppose that length were implemented like this:
extension Complex {
  var naiveLength: RealType {
    .sqrt(real*real + imaginary*imaginary)
  }
}
// Then taking the length of even a modestly large number:
let z = Complex<Float>(1e20, 1e20)
// or small number:
let w = Complex<Float>(1e-24, 1e-24)
// would overflow:
z.naiveLength // Inf
// or underflow:
w.naiveLength // 0
```
Instead, `length` is implemented using a two-step algorithm.
First we compute `lengthSquared`, which is just `x*x + y*y`.
If this is a normal number (meaning that no overflow or underflow has occured), we can safely return its square root.
Otherwise, we redo the computation using the `hypot` function, which takes care to avoid overflow or underflow.

