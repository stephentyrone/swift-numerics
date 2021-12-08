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

// FloatingPoint does not refine Codable, so this is a conditional conformance.
extension SplitComplexVector: Decodable where RealType: Decodable {
  public init(from decoder: Decoder) throws {
    self.init()
    var container = try decoder.unkeyedContainer()
    if let count = container.count {
      self.reserveCapacity(count)
    }
    while !container.isAtEnd {
      let element = try container.decode(Complex<RealType>.self)
      self.append(element)
    }
  }
}

extension SplitComplexVector: Encodable where RealType: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    for element in self {
      try container.encode(element)
    }
  }
}
