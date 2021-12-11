//===--- SplitComplex+Accelerate.swift ------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

#if canImport(Accelerate)
import Accelerate
import RealModule

public protocol AccelerateTransform {
  associatedtype RealType: Real
  var setup: OpaquePointer { get }
}

extension SplitComplexVector {
  public func planDFT(
    _ direction: TransformDirection = .forward
  ) -> DFT<RealType>? {
    DFT(self.count, direction, sharingMemoryWith: nil as DFT<RealType>?)
  }
  
  public func planDFT<Other: AccelerateTransform>(
    _ direction: TransformDirection = .forward,
    sharingMemoryWith other: Other
  ) -> DFT<RealType>? where Other.RealType == RealType {
    DFT(self.count, direction, sharingMemoryWith: other)
  }
}

public class DFT<RealType: Real>: AccelerateTransform {
  
  internal var count: Int
  internal var direction: TransformDirection
  public var setup: OpaquePointer
  
  internal required init?<Other: AccelerateTransform>(
    _ count: Int,
    _ direction: TransformDirection = .forward,
    sharingMemoryWith otherTransform: Other?
  ) where Other.RealType == RealType {
    self.count = count
    self.direction = direction
    let sharedSetup = otherTransform?.setup
    let vDSPCount = vDSP_Length(count)
    let vDSPDir = direction.vDSP
    switch RealType.zero {
    case is Float:
      if let setup = vDSP_DFT_zop_CreateSetup(sharedSetup, vDSPCount, vDSPDir) {
        self.setup = setup
        return
      }
    case is Double:
      if let setup = vDSP_DFT_zop_CreateSetupD(sharedSetup, vDSPCount, vDSPDir) {
        self.setup = setup
        return
      }
    default: break
    }
    return nil
  }
  
  public var inverse: DFT? {
    Self(count, -direction, sharingMemoryWith: self)
  }
  
  public func transform(
    inPlace array: inout SplitComplexVector<RealType>,
    relaxScaling: Bool = false
  ) {
    switch array {
    case let float as SplitComplexVector<Float>:
      vDSP_DFT_Execute(setup, float.x, float.y, float.x, float.y)
    case let double as SplitComplexVector<Double>:
      vDSP_DFT_ExecuteD(setup, double.x, double.y, double.x, double.y)
    default: fatalError()
    }
    // vDSP inverse DFT produces results scaled by count.
    if direction == .inverse && !relaxScaling {
      array.unscale(by: RealType(count))
    }
  }
  
  deinit {
    vDSP_DFT_DestroySetup(setup)
  }
}

@frozen
public struct TransformDirection {
  @usableFromInline
  internal var rawValue: Int
}

extension TransformDirection: Hashable {
  
  public static var forward: Self {
    Self(rawValue: +1)
  }
  
  public static var inverse: Self {
    Self(rawValue: -1)
  }
  
  public static prefix func -(a: Self) -> Self {
    Self(rawValue: -a.rawValue)
  }
  
  @usableFromInline
  internal var vDSP: vDSP_DFT_Direction {
    return vDSP_DFT_Direction(rawValue: Int32(rawValue))!
  }
}

#endif


/*
 // FFT IOS ACCELERATE FRAMEWORK (works only for 2^N samples)
 import Accelerate

 public func fft(x: [Double], y: [Double], type: String) -> ([Double], [Double]) {

     var real = [Double](x)

     var imaginary = [Double](y)

     var splitComplex = DSPDoubleSplitComplex(realp: &real, imagp: &imaginary)

     let length = vDSP_Length(floor(log2(Float(real.count))))

     let radix = FFTRadix(kFFTRadix2)

     let weights = vDSP_create_fftsetupD(length, radix)

     switch type.lowercased() {

     case ("fft"): // CASE FFT
         vDSP_fft_zipD(weights!, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
         vDSP_destroy_fftsetup(weights)

     case ("ifft"): // CASE INVERSE FFT
         vDSP_fft_zipD(weights!, &splitComplex, 1, length, FFTDirection(FFT_INVERSE))
         vDSP_destroy_fftsetup(weights)
         real = real.map({ $0 / Double(x.count) }) // Normalize IFFT by sample count
         imaginary = imaginary.map({ $0 / Double(x.count) }) // Normalize IFFT by sample count

     default: // DEFAULT CASE (FFT)
         vDSP_fft_zipD(weights!, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
         vDSP_destroy_fftsetup(weights)
     }

     return (real, imaginary)
 }

 // END FFT IOS ACCELERATE FRAMEWORK (works only for 2^N samples)

 // DEFINE COMPLEX NUMBERS
 struct Complex<T: FloatingPoint> {
     let real: T
     let imaginary: T
     static func +(lhs: Complex<T>, rhs: Complex<T>) -> Complex<T> {
         return Complex(real: lhs.real + rhs.real, imaginary: lhs.imaginary + rhs.imaginary)
     }

     static func -(lhs: Complex<T>, rhs: Complex<T>) -> Complex<T> {
         return Complex(real: lhs.real - rhs.real, imaginary: lhs.imaginary - rhs.imaginary)
     }

     static func *(lhs: Complex<T>, rhs: Complex<T>) -> Complex<T> {
         return Complex(real: lhs.real * rhs.real - lhs.imaginary * rhs.imaginary,
                        imaginary: lhs.imaginary * rhs.real + lhs.real * rhs.imaginary)
     }
 }

 extension Complex: CustomStringConvertible {
     var description: String {
         switch (real, imaginary) {
         case (_, 0):
             return "\(real)"
         case (0, _):
             return "\(imaginary)i"
         case (_, let b) where b < 0:
             return "\(real) - \(abs(imaginary))i"
         default:
             return "\(real) + \(imaginary)i"
         }
     }
 }

 // DEFINE COMPLEX NUMBERS

 // DFT BASED ON CHIRP Z TRANSFORM (CZT)
 public func dft(x: [Double]) -> ([Double], [Double]) {

     let m = x.count // number of samples

     var N: [Double] = Array(stride(from: Double(0), through: Double(m - 1), by: 1.0))

     N = N.map({ $0 + Double(m) })

     var NM: [Double] = Array(stride(from: Double(-(m - 1)), through: Double(m - 1), by: 1.0))

     NM = NM.map({ $0 + Double(m) })

     var M: [Double] = Array(stride(from: Double(0), through: Double(m - 1), by: 1.0))

     M = M.map({ $0 + Double(m) })

     let nfft = Int(pow(2, ceil(log2(Double(m + m - 1))))) // fft pad

     var p1: [Double] = Array(stride(from: Double(-(m - 1)), through: Double(m - 1), by: 1.0))

     p1 = (zip(p1, p1).map(*)).map({ $0 / Double(2) }) // W = WR + j*WI has to be raised to power p1

     var WR = [Double]()
     var WI = [Double]()

     for i in 0 ..< p1.count { // Use De Moivre's formula to raise to power p1
         WR.append(cos(p1[i] * 2.0 * M_PI / Double(m)))
         WI.append(sin(-p1[i] * 2.0 * M_PI / Double(m)))
     }

     var aaR = [Double]()
     var aaI = [Double]()

     for j in 0 ..< N.count {
         aaR.append(WR[Int(N[j] - 1)] * x[j])
         aaI.append(WI[Int(N[j] - 1)] * x[j])
     }

     let la = nfft - aaR.count

     let pad: [Double] = Array(repeating: 0, count: la) // 1st zero padding

     aaR += pad

     aaI += pad

     let (fgr, fgi) = fft(x: aaR, y: aaI, type: "fft") // 1st FFT

     var bbR = [Double]()
     var bbI = [Double]()

     for k in 0 ..< NM.count {
         bbR.append((WR[Int(NM[k] - 1)]) / (((WR[Int(NM[k] - 1)])) * ((WR[Int(NM[k] - 1)])) + ((WI[Int(NM[k] - 1)])) * ((WI[Int(NM[k] - 1)])))) // take reciprocal
         bbI.append(-(WI[Int(NM[k] - 1)]) / (((WR[Int(NM[k] - 1)])) * ((WR[Int(NM[k] - 1)])) + ((WI[Int(NM[k] - 1)])) * ((WI[Int(NM[k] - 1)])))) // take reciprocal
     }

     let lb = nfft - bbR.count

     let pad2: [Double] = Array(repeating: 0, count: lb) // 2nd zero padding

     bbR += pad2

     bbI += pad2

     let (fwr, fwi) = fft(x: bbR, y: bbI, type: "fft") // 2nd FFT

     let fg = zip(fgr, fgi).map { Complex<Double>(real: $0, imaginary: $1) } // complexN 1

     let fw = zip(fwr, fwi).map { Complex<Double>(real: $0, imaginary: $1) } // complexN 2

     let cc = zip(fg, fw).map { $0 * $1 } // multiply above 2 complex numbers fg * fw

     var ccR = cc.map { $0.real } // real part (vector) of complex multiply

     var ccI = cc.map { $0.imaginary } // imag part (vector) of complex multiply

     let lc = nfft - ccR.count

     let pad3: [Double] = Array(repeating: 0, count: lc) // 3rd zero padding

     ccR += pad3

     ccI += pad3

     let (ggr, ggi) = fft(x: ccR, y: ccI, type: "ifft") // 3rd FFT (IFFT)

     var GGr = [Double]()
     var GGi = [Double]()
     var W2r = [Double]()
     var W2i = [Double]()

     for v in 0 ..< M.count {
         GGr.append(ggr[Int(M[v] - 1)])
         GGi.append(ggi[Int(M[v] - 1)])
         W2r.append(WR[Int(M[v] - 1)])
         W2i.append(WI[Int(M[v] - 1)])
     }

     let ggg = zip(GGr, GGi).map { Complex<Double>(real: $0, imaginary: $1) }

     let www = zip(W2r, W2i).map { Complex<Double>(real: $0, imaginary: $1) }

     let y = zip(ggg, www).map { $0 * $1 }

     let yR = y.map { $0.real } // FFT real part (output vector)

     let yI = y.map { $0.imaginary } // FFT imag part (output vector)

     return (yR, yI)
 }

 // END DFT BASED ON CHIRP Z TRANSFORM (CZT)

 // CHIRP DFT (CZT) TEST
 let x: [Double] = [1, 2, 3, 4, 5] // arbitrary sample size
 let (fftR, fftI) = dft(x: x)
 print("DFT Real Part:", fftR)
 print(" ")
 print("DFT Imag Part:", fftI)

 // Matches Matlab FFT Output
 // DFT Real Part: [15.0, -2.5000000000000018, -2.5000000000000013, -2.4999999999999991, -2.499999999999996]
 // DFT Imag Part: [-1.1102230246251565e-16, 3.4409548011779334, 0.81229924058226477, -0.81229924058226599, -3.4409548011779356]

 // END CHIRP DFT (CZT) TEST
 */
