extension BinaryInteger {
  public init<T>(truncatingIfNeeded source: (high: T, low: T.Magnitude))
  where T: FixedWidthInteger {
    if source.high == T(truncatingIfNeeded: source.low.signbit) {
      // If high is just a sign-extension of low, we can use the single-
      // word init from the standard library.
      self.init(truncatingIfNeeded: source.low)
    } else {
      let highWord = Self(truncatingIfNeeded: source.high)
      self = highWord << T.bitWidth | Self(truncatingIfNeeded: source.low)
    }
  }
  
  public init?<T>(exactly source: (high: T, low: T.Magnitude))
  where T: FixedWidthInteger {
    if source.high == T(truncatingIfNeeded: source.low.signbit) {
      // If high is just a sign-extension of low, we can use the single-
      // word init from the standard library.
      self.init(exactly: source.low)
    } else {
      guard let highWord = Self(exactly: source.high) else { return nil }
      let shifted = highWord << T.bitWidth
      guard shifted >> T.bitWidth == highWord else { return nil }
      self = shifted | Self(truncatingIfNeeded: source.low)
    }
  }
}
