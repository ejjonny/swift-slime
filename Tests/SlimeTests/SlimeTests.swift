import XCTest
@testable import Slime

final class SlimeTests: XCTestCase {
    typealias SlimeClosure = (_ pop: Int, _ iter: Int, _ problemRange: [ClosedRange<Double>]) -> Slime<Double>
    let pop = 10
    let iter = 100
    let runs = 10
    
    let bukinSl: SlimeClosure = {
        Slime(
            populationSize: $0,
            maxIterations: $1,
            problemRange: $2,
            method: .minimize,
            fitnessEvaluation: {
                let x1 = $0[0]
                let x2 = $0[1]
                let expr1 = 100 * sqrt(abs(x2 - 0.01 * pow(x1, 2)))
                let expr2 = 0.01 * abs(x1 + 10)
                return expr1 + expr2
            }
        )
    }
    
    func testBukin() throws {
        let mdn = bench(
            bukinSl,
            [
                (-15)...(-5),
                 -3...3
            ],
            targets: [-10, 1]
        )
        assert(mdn < 5.1)
    }
    
    let crossInTray: SlimeClosure = {
        Slime(
            populationSize: $0,
            maxIterations: $1,
            problemRange: $2,
            method: .minimize,
            fitnessEvaluation: {
                let x1 = $0[0]
                let x2 = $0[1]
                let t1 = sin(x1) * sin(x2)
                let t2 = exp(abs(100 - sqrt(pow(x1, 2) + pow(x2, 2)) / .pi))
                return -0.0001 * pow((abs(t1 * t2) + 1), 0.1)
            }
        )
    }
    
    func testCrossInTray() {
        let mdn = bench(
            crossInTray,
            [
                -10...10,
                 -10...10
            ],
            targets: [1.3491, -1.3491],
            [1.3491, 1.3491],
            [-1.3491, 1.3491],
            [-1.3491, -1.3491]
        )
        assert(mdn < 0.028)
    }
    
    let dropWave: SlimeClosure = {
        Slime(
            populationSize: $0,
            maxIterations: $1,
            problemRange: $2,
            method: .minimize,
            fitnessEvaluation: {
                let x1 = $0[0]
                let x2 = $0[1]
                let t1 = 1 + cos(12 * sqrt(pow(x1, 2) + pow(x2, 2)))
                let t2 = 0.5 * (pow(x1, 2) + pow(x2, 2)) + 2
                return -t1 / t2
            }
        )
    }
    
    func testDropWave() throws {
        let mdn = bench(
            dropWave,
            [
                -5.12...5.12,
                 -5.12...5.12
            ],
            targets: [0, 0]
        )
        assert(mdn < 0.53)
    }
    
    let egg: SlimeClosure = {
        Slime(
            populationSize: $0,
            maxIterations: $1,
            problemRange: $2,
            method: .minimize,
            fitnessEvaluation: {
                let x1 = $0[0]
                let x2 = $0[1]
                let t1 = -(x2 + 47) * sin(sqrt(abs(x2 + x1 / 2 + 47)))
                let t2 = -x1 * sin(sqrt(abs(x1 - (x2 + 47))))
                return t1 + t2
            }
        )
    }
    
    func testEgg() throws {
        let mdn = bench(
            egg,
            [
                -512...512,
                 -512...512
            ],
            targets: [512, 404.2319]
        )
//        assert(mdn < 621)
    }
    
    let gramacyLee: SlimeClosure = {
        Slime(
            populationSize: $0,
            maxIterations: $1,
            problemRange: $2,
            method: .minimize,
            fitnessEvaluation: {
                let x = $0[0]
                let t1 = sin(10 * .pi * x) / (2 * x)
                let t2 = pow((x - 1), 4)
                return t1 + t2
            }
        )
    }
    
    func testGramacyLee() throws {
        let mdn = bench(
            gramacyLee,
            [
                0.5...2.5
            ],
            targets: [0.5486]
        )
        assert(mdn < 0.0001)
    }
    
    let rastigrin: SlimeClosure = {
        Slime(
            populationSize: $0,
            maxIterations: $1,
            problemRange: $2,
            method: .minimize,
            fitnessEvaluation: {
                var sum = 0.0
                for i in 0...2 {
                    let xi = $0[i]
                    sum += pow(xi, 2) - 10 * cos(2 * .pi * xi)
                }
                return 10 * 3 + sum
            }
        )
    }
    
    func testRastigrin() throws {
        let mdn = bench(
            rastigrin,
            [
                -5.12...5.12,
                 -5.12...5.12,
                 -5.12...5.12
            ],
            targets: [0, 0, 0]
        )
        assert(mdn < 2)
    }

    func testTSP() {
        var locations = [
            Point(x: 13.006353983080244, y: 58.32578946151459),
            Point(x: 16.247335344565705, y: 13.301367677596243),
            Point(x: 68.17671912668133, y: 59.78158569380072),
            Point(x: 88.61158548135684, y: 61.88853910114452),
            Point(x: 45.827975777967985, y: 16.974188393950453),
            Point(x: 49.83585976315392, y: 87.12108946511475),
            Point(x: 86.97765491138598, y: 8.450421164333344),
            Point(x: 75.55612774592397, y: 44.29767693919965),
            Point(x: 62.00463421291341, y: 47.395176522021266),
            Point(x: 63.605878647380706, y: 80.25240687401461)
        ]
        
//        var paths = locations.allPermutations()
//        let sorted = paths.sorted { pathA, pathB in
//            pathA.distance < pathB.distance
//        }
//        print(sorted.first!)
//        print(sorted.first!.distance)
        let range = Array((1...locations.count - 2).map { 0...$0 }.reversed())
        var sl = Slime(
            populationSize: 20,
            maxIterations: 200,
            problemRange: range,
            method: .minimize,
            fitnessEvaluation: {
                var locations = locations
                var path = [locations[0]]
                locations.remove(at: 0)
                for i in 0...$0.components.count - 1 {
                    path.append(locations[$0.components[i]])
                    locations.remove(at: $0.components[i])
                }
                path.append(locations[0])
                return path.distance
            }
        )
        sl.run()
        print("Found \(-sl.bestCells[0].fitness) in \(sl.evaluations) evaluations")
        print("Path \(sl.bestCells[0].position)")
        ([0] + sl.bestCells[0].position.components + [0]).forEach {
            print(locations[$0])
            locations.remove(at: $0)
        }
    }
    
    @discardableResult
    func bench(
        _ slime: SlimeClosure,
        pop: Int? = nil,
        iter: Int? = nil,
        _ problemRange: [ClosedRange<Double>],
        targets: Vector<Double>...
    ) -> Double {
        var offs = [Double]()
        for _ in 1...runs {
            var slime = slime(pop ?? self.pop, iter ?? self.iter, problemRange)
            slime.run()
            let closest = targets
                .sorted {
                    let diff1 = Vector.distance(slime.bestCells.avg,$0)
                    let diff2 = Vector.distance(slime.bestCells.avg,$1)
                    return diff1 < diff2
                }
                .first!
            let off = Vector.distance(slime.best.position, closest)
            print(off)
            offs.append(off)
        }
        let avg = offs.avg
        let mdn = offs.mdn
        print("********")
        print("Avg distance from optima: \(avg)")
        print("Median distance from optima: \(mdn)")
        return mdn
    }
}

extension Array where Element == Point {
    var distance: Double {
        var d = 0.0
        for i in 0...self.count - 2 {
            d += Point.distance(lhs: self[i], rhs: self[i + 1])
        }
        d += Point.distance(lhs: self.last!, rhs: self[0])
        return d
    }
}
struct Point: Hashable {
    let x: Double
    let y: Double
    static func distance(lhs: Self, rhs: Self) -> Double {
        sqrt(zip([lhs.x, lhs.y], [rhs.x, rhs.y]).map { pow($0 - $1, 2) }.sum)
    }
}
struct PathComponent: Hashable {
    let pointA: Point
    let pointB: Point
}

extension Vector where Component == Double {
    static func distance(_ lhs: Self, _ rhs: Self) -> Double {
        sqrt(zip(lhs.components, rhs.components).map { pow($0 - $1, 2) }.sum)
    }
    public static func -(lhs: Self, rhs: Self) -> Self {
        .init(
            zip(lhs.components, rhs.components).map {
                $0 - $1
            }
        )
    }
}

extension Array where Element == Double {
    var sum: Double {
        var result = 0.0
        for i in self {
            result += i
        }
        return result
    }
    var avg: Double {
        sum / Double(count)
    }
    var mdn: Double {
        sorted(by: <)[count / 2]
    }
}

extension Array where Element == Cell<Double> {
    var avg: Vector<Double> {
        var components = [Double]()
        for i in first!.position.components.indices {
            components.append(self.map { $0.position[i] }.avg)
        }
        return .init(components)
    }
}

//    func testSelfOptimize() {
//        var sl = Slime(
//            populationSize: 10,
//            lowerBound: [0, 0],
//            upperBound: [1, 1],
//            maxIterations: 100,
//            method: .minimize,
//            fitnessEvaluation: {
//                let pop = $0[0]
//                let iter = $0[1]
//                return self.bench(
//                    { _, _ in self.bukinSl(Int(pop * 100) + 1, Int(iter * 500) + 2) },
//                    [-10, 1]
//                )
//            }
//        )
//        sl.run()
//        print("SL")
//        print(sl.globalBest!)
//    }

extension Array {
    private var decompose : (head: Element, tail: [Element])? {
        return (count > 0) ? (self[0], Array(self[1..<count])) : nil
    }
    
    private func between<T>(x: T, ys: [T]) -> [[T]] {
        if let (head, tail) = ys.decompose {
            return [[x] + ys] + between(x: x, ys: tail).map { [head] + $0 }
        } else {
            return [[x]]
        }
    }
    
    private func permutations<T>(xs: [T]) -> [[T]] {
        if let (head, tail) = xs.decompose {
            return permutations(xs: tail) >>= { permTail in
                self.between(x: head, ys: permTail)
            }
        } else {
            return [[]]
        }
    }
    
    func allPermutations() -> [[Element]] {
        return permutations(xs: self)
    }
}

infix operator >>=
func >>=<A, B>(xs: [A], f: (A) -> [B]) -> [B] {
    return xs.map(f).reduce([], +)
}
