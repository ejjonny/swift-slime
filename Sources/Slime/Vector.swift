public struct Vector: Equatable {
    public var components: [Double]
    public subscript(index: Int) -> Double {
        get {
            components[index]
        }
        set {
            components[index] = newValue
        }
    }
    public init(_ components: [Double]) {
        self.components = components
    }
    init(repeating: Double, count: Int) {
        self = .init([Double](repeating: repeating, count: count))
    }
    static func random(lb: Vector, ub: Vector) -> Self {
        guard ub.components.count == lb.components.count else {
            assertionFailure()
            return .init([])
        }
        return .init(
            zip(lb.components, ub.components).map { bounds in
                Double.random(in: bounds.0...bounds.1)
            }
        )
    }
}

extension Vector: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Double
    public init(arrayLiteral elements: Double...) {
        self.init(elements)
    }
}
