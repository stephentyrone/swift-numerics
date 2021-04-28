// swift-tools-version:5.0
//===--- Package.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import PackageDescription

let package = Package(
  
  name: "swift-numerics",
  products: [
    .library(name: "Numerics", targets: ["Numerics"]),
  ],
  
  targets: [
    // User-facing modules
    .target(name: "ComplexModule", dependencies: ["RealModule"]),
    .target(name: "IntegerModule", dependencies: ["_NumericsShims", "_StaticBuffer"]),
    .target(name: "Numerics", dependencies: ["ComplexModule", "RealModule", "IntegerModule"]),
    .target(name: "RealModule", dependencies: ["_NumericsShims"]),
    
    // Implementation details
    .target(name: "_NumericsShims"),
    .target(name: "_StaticBuffer"),
    .target(name: "_TestSupport", dependencies: ["Numerics"]),
    
    // Unit test bundles
    .testTarget(name: "ComplexTests", dependencies: ["_TestSupport"]),
    .testTarget(name: "RealTests", dependencies: ["_TestSupport"]),
    
    // Test executables
    .target(name: "ComplexLog", dependencies: ["Numerics", "_TestSupport"], path: "Tests/Executable/ComplexLog"),
    .target(name: "ComplexLog1p", dependencies: ["Numerics", "_TestSupport"], path: "Tests/Executable/ComplexLog1p")
  ]
)
