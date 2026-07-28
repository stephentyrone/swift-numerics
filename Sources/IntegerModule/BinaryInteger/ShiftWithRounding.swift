//===--- Shift.swift ------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021-2026 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension BinaryInteger {
  /// `self` divided by 2^(`count`), rounding the result according to `rule`.
  ///
  /// The default rounding rule is `.down`, which matches the behavior of
  /// the `>>` operator from the standard library.
  ///
  /// Some examples of different rounding rules:
  ///
  ///     // 3/2 is 1.5, which rounds (down by default) to 1.
  ///     3.shifted(rightBy: 1)
  ///
  ///     // 1.5 rounds up to 2.
  ///     3.shifted(rightBy: 1, rounding: .up)
  ///
  ///     // The two closest values are 1 and 2, 1 is returned because it
  ///     // is odd.
  ///     3.shifted(rightBy: 1, rounding: .toOdd)
  ///
  ///     // 4/4 is exactly 1, so this does not trap.
  ///     4.shifted(rightBy: 2, rounding: .requireExact)
  ///
  ///     // 5/2 is 2.5, which is not an integer, so this traps.
  ///     5.shifted(rightBy: 1, rounding: .requireExact)
  ///
  /// When `Self(1) << count` is positive, the following are equivalent:
  ///
  ///     a.shifted(rightBy: count, rounding: rule)
  ///     a.divided(by: 1 << count, rounding: rule)
  @_transparent
  public func shifted<Count: BinaryInteger>(
    rightBy count: Count,
    rounding rule: RoundingRule = .down
  ) -> Self {
    self.shifted(
      rightBy: Int(clamping: count),
      rounding: rule
    ).result
  }
  
  /// `self` multiplied by 2^(`count`), rounding the result according
  /// to `rule` if `count` is negative.
  ///
  /// The default rounding rule is `.down`, which matches the behavior of
  /// the `<<` operator from the standard library.
  @_transparent
  public func shifted<Count: BinaryInteger>(
    leftBy count: Count,
    rounding rule: RoundingRule = .down
  ) -> Self {
    self.shifted(
      rightBy: Int(clamping: count).negatedWithSaturation(),
      rounding: rule
    ).result
  }
  
  @inlinable
  package func shifted(
    rightBy count: Int,
    rounding rule: RoundingRule = .down
  ) -> (result: Self, didRound: Bool) {
    // Easiest case: count is zero or negative, so shift is always exact;
    // delegate to the normal >> operator.
    if count <= 0 {
      return (self >> count, false)
    }
    // If count is over-large, we round in two steps; the first consumes all
    // but bitWidth-1 bits, and is done with sticky rounding
    if count >= bitWidth {
      // Note: what follows would cause an infinite loop if bitWidth <= 1.
      // This will essentially never happen, but in the highly unlikely event
      // that we encounter such a case, we promote to Int8, do the shift, and
      // then convert back to the appropriate result type.
      if bitWidth <= 1 {
        let (wideResult, didRound) = Int8(self).shifted(
          rightBy: count, rounding: rule
        )
        return (Self(wideResult), didRound)
      }
      // That pathological case taken care of, we can now handle over-wide
      // shifts by first shifting all but bitWidth - 1 bits with sticky
      // rounding, and then shifting the remaining bitWidth - 1 bits with
      // the desired rounding mode.
      let count = count - (bitWidth - 1)
      let floor = self >> count
      let lost = self - (floor << count)
      let sticky = floor | (lost == 0 ? 0 : 1)
      return sticky.shifted(rightBy: bitWidth - 1, rounding: rule)
    }
    // Now we are in the happy case: 0 < count < bitWidth, which makes all
    // the math to handle rounding simpler.
    //
    // TODO: If we were really, really careful about overflow, some of these
    // could be made simpler. E.g. mathematically round up is implemented here
    // via:
    //
    //   floor = self >> count
    //   mask = 1 << count - 1
    //   lost = self & mask
    //   return floor + (lost == 0 ? 0 : 1)
    //
    // _if_ we didn't have to worry about intermediate overflow (either because
    // self is bounded away from .max or because we don't have a fixed-width
    // type), then we could use the following instead:
    //
    //   mask = 1 << count - 1
    //   return (self + mask) >> count
    //
    // However, self + mask can overflow, e.g. if we're shifting .max by 1:
    //
    //   mask = 1 << 1 - 1 = 1
    //   self + mask = .max + 1 // uh-oh
    //
    // This cannot occur for arbitrary-precision numbers, so we could use
    // the simpler expressions for those (but those are precisely the cases
    // where performance of rounding does not matter much, because shifts
    // get swamped by even basic arithmetic). More interesting, we could
    // promote fixed-width numbers to a wider type, preventing this
    // intermediate overflow and allowing us to use the simpler expressions
    // much of the time. We could also explicitly _detect_ the overflow if
    // it happens and patch up the result, though this is a little bit tricky
    // because addingReportingOverflow and friends do not exist on
    // BinaryInteger. Hence, this is a TODO for the future.
    let mask = Magnitude(1) << count - 1
    let lost = Magnitude(truncatingIfNeeded: self) & mask
    let floor = self >> count
    if lost == 0 { return (floor, false) }
    let half: Magnitude = (1 as Magnitude) << (count &- 1)
    switch rule {
    case .down:
      return (floor, true)
    case .up:
      return (floor + 1, true)
    case .towardZero:
      return (floor + (self < 0 ? 1 : 0), true)
    case .awayFromZero:
      return (floor + (self > 0 ? 1 : 0), true)
    case .toNearestOrDown:
      return (floor + Self((lost + (half - 1)) >> count), true)
    case .toNearestOrUp:
      return (floor + Self((lost + half) >> count), true)
    case .toNearestOrZero:
      let round = half - (self < 0 ? 0 : 1)
      return (floor + Self((round + lost) >> count), true)
    case .toNearestOrAway:
      let round = half - (self > 0 ? 0 : 1)
      return (floor + Self((round + lost) >> count), true)
    case .toNearestOrEven:
      let round = mask >> 1 + Magnitude(floor & 1)
      return (floor + Self((round + lost) >> count), true)
    case .toOdd:
      return (floor | (lost == 0 ? 0 : 1), true)
    case .requireExact:
      fatalError("shift was not exact.")
    }
  }
}
