public struct Vector<Component>: Equatable, Hashable where Component: SlimeComponent {
    public var components: [Component]
    public subscript(index: Int) -> Component {
        get {
            components[index]
        }
        set {
            components[index] = newValue
        }
    }
    public init(_ components: [Component]) {
        self.components = components
    }
    init(repeating: Component, count: Int) {
        self = .init([Component](repeating: repeating, count: count))
    }
    static func random(in range: [ClosedRange<Component>]) -> Self {
        return .init(
            range.map { Component.random(in: $0) }
        )
    }
}

extension Vector: ExpressibleByArrayLiteral where Component: SlimeComponent {
    public typealias ArrayLiteralElement = Component
    public init(arrayLiteral elements: Component...) {
        self.init(elements)
    }
}

public protocol SlimeComponent: Comparable, Hashable {
    static func random(in: ClosedRange<Self>) -> Self
    var isNaN: Bool { get }
    static func -(lhs: Self, rhs: Self) -> Self
    static func +(lhs: Self, rhs: Self) -> Self
    static func *(lhs: Self, rhs: Self) -> Self
    static func /(lhs: Self, rhs: Self) -> Self
    var doubleValue: Double { get }
    init(_ value: Double)
}

extension Double: SlimeComponent {
    public var doubleValue: Double {
        self
    }
    init<Component>(_ value: Component) where Component: SlimeComponent {
        self = value.doubleValue
    }
}
extension Int: SlimeComponent {
    public var isNaN: Bool {
        false
    }
    public var doubleValue: Double {
        Double(self)
    }
}
