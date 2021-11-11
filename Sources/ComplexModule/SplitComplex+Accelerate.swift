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
    switch RealType.zero {
    case is Float:
      if let setup = vDSP_DFT_zop_CreateSetup(
        otherTransform?.setup,
        vDSP_Length(count),
        direction.vDSP
      ) {
        self.setup = setup
        return
      }
    case is Double:
      if let setup = vDSP_DFT_zop_CreateSetupD(
        otherTransform?.setup,
        vDSP_Length(count),
        direction.vDSP
      ) {
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
  
  public func transform(inPlace array: inout SplitComplexVector<RealType>) {
    switch array {
    case let float as SplitComplexVector<Float>:
      vDSP_DFT_Execute(setup, float.x, float.y, float.x, float.y)
    case let double as SplitComplexVector<Double>:
      vDSP_DFT_ExecuteD(setup, double.x, double.y, double.x, double.y)
    default: fatalError()
    }
    // TODO: "correct" scaling; inverse transform has an implicit scale by count.
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
