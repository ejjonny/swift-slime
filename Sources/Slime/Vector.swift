public protocol Vector: Equatable where Scalar: BinaryFloatingPoint, Scalar.RawSignificand: FixedWidthInteger {
    associatedtype Scalar
    static func random(lower: Self, upper: Self) -> Self
    static func random(in range: ClosedRange<Scalar>) -> Self
    var scalarCount: Int { get }
    static func + (a: Self, b: Self) -> Self
    static func - (a: Self, b: Self) -> Self
    static func * (a: Self, b: Self) -> Self
    static func / (a: Self, b: Self) -> Self
    static func + (a: Self.Scalar, b: Self) -> Self
    static func - (a: Self.Scalar, b: Self) -> Self
    static func * (a: Self.Scalar, b: Self) -> Self
    static func / (a: Self.Scalar, b: Self) -> Self
    static func + (a: Self, b: Self.Scalar) -> Self
    static func - (a: Self, b: Self.Scalar) -> Self
    static func * (a: Self, b: Self.Scalar) -> Self
    static func / (a: Self, b: Self.Scalar) -> Self
    static func += (a: inout Self, b: Self)
    static func -= (a: inout Self, b: Self)
    static func *= (a: inout Self, b: Self)
    static func /= (a: inout Self, b: Self)
    static func += (a: inout Self, b: Self.Scalar)
    static func -= (a: inout Self, b: Self.Scalar)
    static func *= (a: inout Self, b: Self.Scalar)
    static func /= (a: inout Self, b: Self.Scalar)
    mutating func clamp(lowerBound: Self, upperBound: Self)
}

extension SIMD2: Vector where Scalar: BinaryFloatingPoint, Scalar.RawSignificand: FixedWidthInteger {}
extension SIMD3: Vector where Scalar: BinaryFloatingPoint, Scalar.RawSignificand: FixedWidthInteger {}
extension SIMD4: Vector where Scalar: BinaryFloatingPoint, Scalar.RawSignificand: FixedWidthInteger {}
extension SIMD8: Vector where Scalar: BinaryFloatingPoint, Scalar.RawSignificand: FixedWidthInteger {}
extension SIMD16: Vector where Scalar: BinaryFloatingPoint, Scalar.RawSignificand: FixedWidthInteger {}
extension SIMD32: Vector where Scalar: BinaryFloatingPoint, Scalar.RawSignificand: FixedWidthInteger {}
extension SIMD64: Vector where Scalar: BinaryFloatingPoint, Scalar.RawSignificand: FixedWidthInteger {}

extension SIMD where Scalar: BinaryFloatingPoint, Scalar.RawSignificand: FixedWidthInteger {
    @inlinable
    public static func random(
        lower: Self,
        upper: Self
    ) -> Self {
        var result = Self()
        for i in result.indices {
            result[i] = Scalar.random(in: lower[i]..<upper[i])
        }
        return result
    }
}

extension Double: Vector {
    public var scalarCount: Int { 1 }
    
    public static func random(lower: Self, upper: Self) -> Self {
        .random(in: lower...upper)
    }
    
    public mutating func clamp(lowerBound: Self, upperBound: Self) {
        if self > upperBound {
            self = upperBound
        } else if self < lowerBound {
            self = lowerBound
        }
    }
}

extension Float: Vector {
    public var scalarCount: Int { 1 }
    
    public static func random(lower: Self, upper: Self) -> Self {
        .random(in: lower...upper)
    }
    
    public mutating func clamp(lowerBound: Self, upperBound: Self) {
        if self > upperBound {
            self = upperBound
        } else if self < lowerBound {
            self = lowerBound
        }
    }
}
