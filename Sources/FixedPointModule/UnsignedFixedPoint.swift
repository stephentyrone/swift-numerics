//===--- UnsignedFixedPoint.swift -----------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension FixedPoint where IntegerType: UnsignedInteger {
  
  public typealias Magnitude = Self
  
  @_transparent
  public var magnitude: Self { self }
}
