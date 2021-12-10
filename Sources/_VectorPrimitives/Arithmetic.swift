import RealModule

#if canImport(Accelerate)
import Accelerate
#endif

@_specialize(exported: true, where T == Float)
@_specialize(exported: true, where T == Double)
public func smul<T: FloatingPoint>(inPlace x: UnsafeMutablePointer<T>, _ a: T, _ n: Int) {
#if canImport(Accelerate)
  if _isConcrete(T.self) {
    switch (a, x) {
    case (var at, let xt) as (Float, UnsafeMutablePointer<Float>):
      vDSP_vsmul(xt, 1, &at, xt, 1, vDSP_Length(clamping: n))
      return
    case (var at, let xt) as (Double, UnsafeMutablePointer<Double>):
      vDSP_vsmulD(xt, 1, &at, xt, 1, vDSP_Length(clamping: n))
      return
    default:
      break
    }
  }
#endif
  for i in 0 ..< n { x[i] *= a }
}

@_specialize(exported: true, where T == Float)
@_specialize(exported: true, where T == Double)
public func sdiv<T: FloatingPoint>(inPlace x: UnsafeMutablePointer<T>, _ a: T, _ n: Int) {
  for i in 0 ..< n { x[i] /= a }
}

@_specialize(exported: true, where T == Float)
@_specialize(exported: true, where T == Double)
public func vadd<T: FloatingPoint>(inPlace x: UnsafeMutablePointer<T>, _ y: UnsafePointer<T>, _ n: Int) {
#if canImport(Accelerate)
  if _isConcrete(T.self) {
    switch (x, y) {
    case let (xt, yt) as (UnsafeMutablePointer<Float>, UnsafePointer<Float>):
      vDSP_vadd(xt, 1, yt, 1, xt, 1, vDSP_Length(clamping: n))
      return
    case let (xt, yt) as (UnsafeMutablePointer<Double>, UnsafePointer<Double>):
      vDSP_vaddD(xt, 1, yt, 1, xt, 1, vDSP_Length(clamping: n))
      return
    default:
      break
    }
  }
#endif
  for i in 0 ..< n { x[i] += y[i] }
}

@_specialize(exported: true, where T == Float)
@_specialize(exported: true, where T == Double)
public func vadd<T: FloatingPoint>(
  result r: UnsafeMutablePointer<T>,
  _ x: UnsafePointer<T>,
  _ y: UnsafePointer<T>,
  _ n: Int
) {
#if canImport(Accelerate)
  if _isConcrete(T.self) {
    switch (x, y, r) {
    case let (xt, yt, rt) as (UnsafePointer<Float>, UnsafePointer<Float>, UnsafeMutablePointer<Float>):
      vDSP_vadd(xt, 1, yt, 1, rt, 1, vDSP_Length(clamping: n))
      return
    case let (xt, yt, rt) as (UnsafePointer<Double>, UnsafePointer<Double>, UnsafeMutablePointer<Double>):
      vDSP_vaddD(xt, 1, yt, 1, rt, 1, vDSP_Length(clamping: n))
      return
    default:
      break
    }
  }
#endif
  for i in 0 ..< n { r[i] = x[i] + y[i] }
}

@_specialize(exported: true, where T == Float)
@_specialize(exported: true, where T == Double)
public func vsub<T: FloatingPoint>(inPlace x: UnsafeMutablePointer<T>, _ y: UnsafePointer<T>, _ n: Int) {
#if canImport(Accelerate)
  if _isConcrete(T.self) {
    switch (x, y) {
    case let (xt, yt) as (UnsafeMutablePointer<Float>, UnsafePointer<Float>):
      vDSP_vsub(xt, 1, yt, 1, xt, 1, vDSP_Length(clamping: n))
      return
    case let (xt, yt) as (UnsafeMutablePointer<Double>, UnsafePointer<Double>):
      vDSP_vsubD(xt, 1, yt, 1, xt, 1, vDSP_Length(clamping: n))
      return
    default:
      break
    }
  }
#endif
  for i in 0 ..< n { x[i] -= y[i] }
}

@_specialize(exported: true, where T == Float)
@_specialize(exported: true, where T == Double)
public func vsub<T: FloatingPoint>(
  result r: UnsafeMutablePointer<T>,
  _ x: UnsafePointer<T>,
  _ y: UnsafePointer<T>,
  _ n: Int
) {
#if canImport(Accelerate)
  if _isConcrete(T.self) {
    switch (x, y, r) {
    case let (xt, yt, rt) as (UnsafePointer<Float>, UnsafePointer<Float>, UnsafeMutablePointer<Float>):
      vDSP_vsub(xt, 1, yt, 1, rt, 1, vDSP_Length(clamping: n))
      return
    case let (xt, yt, rt) as (UnsafePointer<Double>, UnsafePointer<Double>, UnsafeMutablePointer<Double>):
      vDSP_vsubD(xt, 1, yt, 1, rt, 1, vDSP_Length(clamping: n))
      return
    default:
      break
    }
  }
#endif
  for i in 0 ..< n { r[i] = x[i] - y[i] }
}

@_specialize(exported: true, where T == Float)
@_specialize(exported: true, where T == Double)
public func maxmgv<T: FloatingPoint>(_ x: UnsafePointer<T>, _ n: Int) -> T {
#if canImport(Accelerate)
  if _isConcrete(T.self) {
    switch x {
    case let xt as UnsafePointer<Float>:
      var result: Float = 0
      vDSP_maxmgv(xt, 1, &result, vDSP_Length(clamping: n))
      return result as! T
    case let xt as UnsafePointer<Double>:
      var result: Double = 0
      vDSP_maxmgvD(xt, 1, &result, vDSP_Length(clamping: n))
      return result as! T
    default:
      break
    }
  }
#endif
  return (0 ..< n).reduce(into: .zero) { $0 = T.maximumMagnitude(x[$1], $0) }
}
