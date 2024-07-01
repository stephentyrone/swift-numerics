//===--- String.swift -----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import IntegerUtilities

extension FixedPoint {
  // TODO: add rounding control
  public init?(_ description: String) {
    // TODO: bypass double to avoid double-roundings
    guard let d = Double(description) else { return nil }
    self.init(exactly: d)
  }
  
  public var description: String {
    var result = ""
    if self < 0 { result = "-" }
    // isolate integral part and format as string using the existing integer
    // support
    result += String(bitPattern.magnitude >> Self.fractionBits)
    result += "."
    // isolate and left-align fractional part
    var fraction = bitPattern.magnitude << Self.integralBits
    // We need at most one decimal digit for each fractional bit
    for _ in 0 ..< Self.fractionBits {
      // Peel off one digit via multiply-high
      let (digit, residual) = fraction.multipliedFullWidth(by: 10)
      result += "\(digit)"
      if residual == 0 { break }
      fraction = residual
    }
    return result
  }
}

/* TODO: add rounding support, polish, etc
extension String {
  @inlinable @inline(never) // specialize
  public init<Fixed: FixedPoint>(
    _ fixed: Fixed,
    radix: Int = 10,
    fractionalDigits: Int? = nil,
    rounding rule: RoundingRule = .toNearestOrEven,
    alwaysPrintSign: Bool = false
  ) {
    if fixed.bitPattern < 0 { self = "-" }
    else if alwaysPrintSign { self = "+" }
    else { self = "" }
    // print integer part
    let magnitude = fixed.bitPattern.magnitude
    self += String(magnitude &>> Fixed.fractionBits)
    self += "."
    // isolate fraction
    var fraction = magnitude &<< Fixed.integralBits
    var unit = Fixed.IntegerType.Magnitude(1) &<< Fixed.integralBits
    var digits = fractionalDigits ?? Fixed.fractionBits
    let r = Fixed.IntegerType.Magnitude(radix)
    while digits > 0 {
      let (dig, tail) = bits.multipliedFullWidth(by: r)
      self += "\(dig)"
      let (hi, low) = unit.multipliedFullWidth(by: r)
      if tail == 0 /*shortest WIP: hi != 0 ||  tail < low */ { break }
      bits = tail
      unit = low
      digits -= 1
    }
  }
}
*/
