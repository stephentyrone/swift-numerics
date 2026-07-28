import Builtin

extension BinaryInteger {
  /// `other` rounded to an integral value according to `rule`
  ///
  /// If the rounded value is not representable in this type, `nil` is
  /// returned.
  public init?(
    _ other: some BinaryFloatingPoint,
    rounding rule: RoundingRule
  ) {
    self.init(exactly: other.rounding(rule))
  }
  
  /// Get boolean value (0 or 1) as a pure arithmetic operation.
  ///
  /// Semantically this is identical to (bool ? 1 : 0) but even though that
  /// --on its own--will generate essential identical code, it creates extra
  /// basic blocks at the LLVM IR level that prevent the formation of optimal
  /// add-with-carry and subtract-with-carry/borrow sequences. Doing it this
  /// way instead does not introduce any control flow at the IR level and
  /// allows optimal codegen for bignum arithmetic.
  @_transparent
  public init(zeroExtending bool: Bool) {
    // Two-step conversion, will get folded down to a single zext to whatever
    // Self is if it's a type that LLVM knows about, and a conversion from
    // UInt8 otherwise, which ought to be pretty efficient for any sane
    // integer type.
    self.init(
      truncatingIfNeeded: UInt8(Builtin.zextOrBitCast_Int1_Int8(bool._value))
    )
  }
}
