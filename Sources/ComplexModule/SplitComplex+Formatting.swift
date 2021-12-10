extension SplitComplexVector: CustomStringConvertible {
  public var description: String {
    return "[" + map(\.description).joined(separator: ", ") + "]"
  }
}

extension SplitComplexVector: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Complex<RealType>...) {
    self.init(capacity: elements.count)
    self.append(contentsOf: elements)
  }
}
