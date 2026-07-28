prefix operator -?
infix operator *?: MultiplicationPrecedence
infix operator /?: MultiplicationPrecedence
infix operator %?: MultiplicationPrecedence
infix operator +?: AdditionPrecedence
infix operator -?: AdditionPrecedence
infix operator *?=: AssignmentPrecedence
infix operator /?=: AssignmentPrecedence
infix operator %?=: AssignmentPrecedence
infix operator +?=: AssignmentPrecedence
infix operator -?=: AssignmentPrecedence

extension Optional where Wrapped: FixedWidthInteger {
  
  @inlinable @inline(__always)
  public static prefix func -?(a: Self) -> Self { 0 -? a }
  
  @inlinable @inline(__always)
  public static func *?(a: Self, b: Self) -> Self {
    guard let a, let b else { return nil }
    guard case let (r, false) = a.multipliedReportingOverflow(by: b) else { return nil }
    return r
  }
  
  @inlinable @inline(__always)
  public static func /?(a: Self, b: Self) -> Self {
    guard let a, let b else { return nil }
    guard case let (r, false) = a.dividedReportingOverflow(by: b) else { return nil }
    return r
  }
  
  @inlinable @inline(__always)
  public static func %?(a: Self, b: Self) -> Self {
    guard let a, let b else { return nil }
    guard case let (r, false) = a.remainderReportingOverflow(dividingBy: b) else { return nil }
    return r
  }
  
  @inlinable @inline(__always)
  public static func +?(a: Self, b: Self) -> Self {
    guard let a, let b else { return nil }
    guard case let (r, false) = a.addingReportingOverflow(b) else { return nil }
    return r
  }
  
  @inlinable @inline(__always)
  public static func -?(a: Self, b: Self) -> Self {
    guard let a, let b else { return nil }
    guard case let (r, false) = a.subtractingReportingOverflow(b) else { return nil }
    return r
  }
  
  @inlinable @inline(__always)
  public static func *?=(a: inout Self, b: Self) {
    a = a *? b
  }
  
  @inlinable @inline(__always)
  public static func /?=(a: inout Self, b: Self) {
    a = a /? b
  }
  
  @inlinable @inline(__always)
  public static func %?=(a: inout Self, b: Self) {
    a = a %? b
  }
  
  @inlinable @inline(__always)
  public static func +?=(a: inout Self, b: Self) {
    a = a +? b
  }
  
  @inlinable @inline(__always)
  public static func -?=(a: inout Self, b: Self) {
    a = a -? b
  }
}
