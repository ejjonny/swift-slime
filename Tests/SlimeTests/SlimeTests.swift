import XCTest
import simd
@testable import Slime

final class SlimeTests: XCTestCase {
    let pop = 10
    let iter = 100
    let runs = 100

    func testBukin() throws {
        let target = SIMD2(-10.0, 1.0)
        var loss = [Double]()
        for _ in 1...runs {
            var slime = Slime(
                populationSize: pop,
                maxIterations: iter,
                lower: SIMD2(-15.0, -3.0),
                upper: SIMD2(-5.0, 3.0),
                method: .minimize
            ) {
                let x1 = $0[0]
                let x2 = $0[1]
                let expr1 = 100 * sqrt(abs(x2 - 0.01 * pow(x1, 2)))
                let expr2 = 0.01 * abs(x1 + 10)
                return expr1 + expr2
            }
            slime.run()
            let off = simd_distance(target, slime.best.position)
            loss.append(off)
        }
        let avg = loss.avg
        let mdn = loss.mdn
        print("********")
        print("Avg distance from optima: \(avg)")
        print("Median distance from optima: \(mdn)")

        assert(mdn < 5.1)
    }
    
    func testCrossInTray() throws {
        let targets = [
            SIMD2(1.3491, -1.3491),
            SIMD2(1.3491, 1.3491),
            SIMD2(-1.3491, 1.3491),
            SIMD2(-1.3491, -1.3491)
        ]
        var loss = [Double]()
        for _ in 1...runs {
            var slime = Slime(
                populationSize: pop,
                maxIterations: iter,
                lower: SIMD2(-10.0, -10.0),
                upper: SIMD2(10.0, 10.0),
                method: .minimize
            ) {
                let x1 = $0[0]
                let x2 = $0[1]
                let t1 = sin(x1) * sin(x2)
                let t2 = exp(abs(100 - sqrt(pow(x1, 2) + pow(x2, 2)) / .pi))
                return -0.0001 * pow((abs(t1 * t2) + 1), 0.1)
            }
            slime.run()
            let closest = targets
                .sorted { targetA, targetB in
                    simd_distance(targetA, slime.best.position) < simd_distance(targetB, slime.best.position)
                }
                .first!
            let off = simd_distance(closest, slime.best.position)
            loss.append(off)
        }
        let avg = loss.avg
        let mdn = loss.mdn
        print("********")
        print("Avg distance from optima: \(avg)")
        print("Median distance from optima: \(mdn)")

        assert(mdn < 0.028)
    }

    func testDropWave() throws {
        let target = SIMD2(0.0, 0.0)
        var loss = [Double]()
        for _ in 1...runs {
            var slime = Slime(
                populationSize: pop,
                maxIterations: iter,
                lower: SIMD2(-5.12, -5.12),
                upper: SIMD2(5.12, 5.12),
                method: .minimize
            ) {
                let x1 = $0[0]
                let x2 = $0[1]
                let t1 = 1 + cos(12 * sqrt(pow(x1, 2) + pow(x2, 2)))
                let t2 = 0.5 * (pow(x1, 2) + pow(x2, 2)) + 2
                return -t1 / t2
            }
            slime.run()
            let off = simd_distance(target, slime.best.position)
            loss.append(off)
        }
        let avg = loss.avg
        let mdn = loss.mdn
        print("********")
        print("Avg distance from optima: \(avg)")
        print("Median distance from optima: \(mdn)")

        assert(mdn < 0.53)
    }
    
    func testEgg() throws {
        let target = SIMD2(512.0, 404.2319)
        var loss = [Double]()
        for _ in 1...runs {
            var slime = Slime(
                populationSize: pop,
                maxIterations: iter,
                lower: SIMD2(-512, -512),
                upper: SIMD2(512, 512),
                method: .minimize
            ) {
                let x1 = $0[0]
                let x2 = $0[1]
                let t1 = -(x2 + 47) * sin(sqrt(abs(x2 + x1 / 2 + 47)))
                let t2 = -x1 * sin(sqrt(abs(x1 - (x2 + 47))))
                return t1 + t2
            }
            slime.run()
            let off = simd_distance(target, slime.best.position)
            loss.append(off)
        }
        let avg = loss.avg
        let mdn = loss.mdn
        print("********")
        print("Avg distance from optima: \(avg)")
        print("Median distance from optima: \(mdn)")

        assert(mdn < 621)
    }

    func testGramacy() throws {
        let target = 0.5486
        var loss = [Double]()
        for _ in 1...runs {
            var slime = Slime(
                populationSize: pop,
                maxIterations: iter,
                lower: 0.5,
                upper: 2.5,
                method: .minimize
            ) {
                let x = $0
                let t1 = sin(10 * .pi * x) / (2 * x)
                let t2 = pow((x - 1), 4)
                return t1 + t2
            }
            slime.run()
            let off = abs(target - slime.best.position)
            loss.append(off)
        }
        let avg = loss.avg
        let mdn = loss.mdn
        print("********")
        print("Avg distance from optima: \(avg)")
        print("Median distance from optima: \(mdn)")

        assert(mdn < 0.0001)
    }
    
    func testRastigrin() throws {
        let target = SIMD3(0.0, 0.0, 0.0)
        var loss = [Double]()
        for _ in 1...runs {
            var slime = Slime(
                populationSize: pop,
                maxIterations: iter,
                lower: SIMD3(-5.12, -5.12, -5.12),
                upper: SIMD3(5.12, 5.12, 5.12),
                method: .minimize
            ) {
                var sum = 0.0
                for i in 0...2 {
                    let xi = $0[i]
                    sum += pow(xi, 2) - 10 * cos(2 * .pi * xi)
                }
                return 10 * 3 + sum
            }
            slime.run()
            let off = simd_distance(target, slime.best.position)
            loss.append(off)
        }
        let avg = loss.avg
        let mdn = loss.mdn
        print("********")
        print("Avg distance from optima: \(avg)")
        print("Median distance from optima: \(mdn)")

        assert(mdn < 2)
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

//extension Array where Element == Slime<.Cell {
//    var avg: Vector {
//        var components = [Double]()
//        for i in first!.position.components.indices {
//            components.append(self.map { $0.position[i] }.avg)
//        }
//        return .init(components)
//    }
//}

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
