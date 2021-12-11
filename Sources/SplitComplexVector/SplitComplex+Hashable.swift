//===--- SplitComplex+Hashable.swift --------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension SplitComplexVector: Equatable {
  @inlinable
  public static func ==(
    lhs: SplitComplexVector<RealType>,
    rhs: SplitComplexVector<RealType>
  ) -> Bool {
    lhs.elementsEqual(rhs)
  }
}

extension SplitComplexVector: Hashable {
  @inlinable
  public func hash(into hasher: inout Hasher) {
    hasher.combine(count) // discriminator
    for element in self {
      hasher.combine(element)
    }
  }
}
