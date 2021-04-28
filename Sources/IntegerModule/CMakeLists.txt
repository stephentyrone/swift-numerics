#[[
This source file is part of the Swift Numerics open source project

Copyright (c) 2021 Apple Inc. and the Swift Numerics project authors
Licensed under Apache License v2.0 with Runtime Library Exception

See https://swift.org/LICENSE.txt for license information
#]]

add_library(IntegerModule
  ArithmeticCore.swift)
set_target_properties(IntegerModule PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})
target_link_libraries(RealModule PUBLIC
  _NumericsShims
  _StaticBuffer)


_install_target(IntegerModule)
set_property(GLOBAL APPEND PROPERTY SWIFT_NUMERICS_EXPORTS IntegerModule)


