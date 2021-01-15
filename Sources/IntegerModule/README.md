# Integer Utilities

The `IntegerModule` provides API for working with integer types and values, building
off the protocols defined by the Swift standard library.

### Extensions to `FixedWidthInteger & UnsignedInteger`

- Bitwise Rotation
  ```swift
  public func rotated<T: BinaryInteger>(right count: T) -> Self
  public func rotated<T: BinaryInteger>(left count: T) -> Self
  ```
  Rotation is just like a shift, but instead of discarding bits as they are shifted off, they are inserted on the other side of the bit pattern.
  This is easiest to explain with a small example; consider `UInt8(11).rotated(right: 1)`.
  `UInt8(11)` has the bit pattern `0000_1011`.
  If we _shifted_ it right, the least-significant `1` bit would be shifted off, and a zero would be inserted in the most-significant position, yielding `0000_0101`.
  Rotating it right means that instead of inserting zeros, we insert the bits that are shifted off, yielding `1000_0101`, or 133.
  All the possible rotations are listed below as further examples:
  ```swift
  let a: UInt8 = 11   // bit pattern   value
  a.rotated(right: 1) //  10000101      133
  a.rotated(right: 2) //  11000010      194
  a.rotated(right: 3) //  01100001       97
  a.rotated(right: 4) //  10110000      176
  a.rotated(right: 5) //  01011000       88
  a.rotated(right: 6) //  00101100       44
  a.rotated(right: 7) //  00010110       22
  a.rotated(right: 8) //  00001011       11
  ```
  Note that because `UInt8` is eight bits wide, `a.rotated(right: 8)` is the same as `a`, so the pattern simply repeats itself from here on.
  Because of this, the count can never be "out of range", even for negative counts, and there is no need for a "masking" variant as with shifts.
  For instance, `a.rotated(right: -2)` is the same as `a.rotated(right: 6)` and `a.rotated(left: 2)`.

### Dependencies:
None
