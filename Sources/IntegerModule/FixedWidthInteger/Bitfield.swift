import Builtin

extension FixedWidthInteger {
  /// Access to a bitfield of the integer.
  ///
  /// Bits are indexed from zero (the least-significant) to bitWidth-1 (the
  /// most-significant). A `get` operation extracts the specified bits, and
  /// zero-extends them if needed to fill the result type.
  ///
  /// Example:
  /// ```swift
  /// let x: Int16 = 0b1000_1010_1111_0111
  /// let y: Int8 = x[bits: 11 ..< 16]
  /// // bit index: fedcba9876543210
  /// // bit value: 1000101011110111
  /// // bit 11-16: ^^^^^
  /// //  extract :     +----------v
  /// //          :            10001
  /// // zero ext :       0b00010001
  /// ```
  ///
  /// If the requested bitfield is too wide to fit in the result type, a
  /// runtime trap occurs. If the bounds of the bitfield are outside of the
  /// valid bit indexes, a runtime trap occurs.
  public subscript<Other: FixedWidthInteger>(
    bits range: Range<Int>, as type: Other.Type = Other.self
  ) -> Other {
    @_transparent get {
      precondition(range.lowerBound >= 0)
      precondition(range.upperBound <= Self.bitWidth)
      let width = range.upperBound - range.lowerBound
      precondition(width <= Other.bitWidth)
      let mask: Self = 1 &<< width &- 1
      return Other(truncatingIfNeeded: self &>> range.lowerBound & mask)
    }
    
    @_transparent set {
      precondition(range.lowerBound >= 0)
      precondition(range.upperBound <= Self.bitWidth)
      let width = range.upperBound - range.lowerBound
      precondition(width <= Other.bitWidth)
      let mask: Self = 1 &<< width &- 1
      self &= ~(mask &<< range.lowerBound)
      self |= (Self(truncatingIfNeeded: newValue) & mask) &<< range.lowerBound
    }
  }
  
  // When setting, we can always infer a type from newValue, but in a getter,
  // we might not be able to (e.g. let x = y[bits: 2..<5]). It would be
  // annoying and error-prone to make people always specify, so we provide a
  // concrete getter overload that specifies `Self`, which is guaranteed to
  // always be able to represent a bitfield.
  public subscript(bits range: Range<Int>) -> Self {
    @_transparent
    get { self[bits: range, as: Self.self] }
  }
  
  public subscript(bit index: Int) -> Bool {
    @_transparent
    get {
      precondition(index >= 0 && index <= Self.bitWidth)
      return self &>> index & 1 != 0
    }
    @_transparent
    set {
      precondition(index >= 0 && index <= Self.bitWidth)
      self &= ~(1 &<< index)
      self |= Self(zeroExtending: newValue) &<< index
    }
  }
}
