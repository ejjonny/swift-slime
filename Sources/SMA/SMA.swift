import Numerics

public protocol SMACoordinate where Self: Comparable {
    init(_ value: Double)
    static func random(in range: ClosedRange<Self>) -> Self
    static func *(lhs: Self, rhs: Self) -> Self
    static func /(lhs: Self, rhs: Self) -> Self
    static func +(lhs: Self, rhs: Self) -> Self
    static func -(lhs: Self, rhs: Self) -> Self
    var isNaN: Bool { get }
}

public struct Cell<Coordinate>: Equatable where Coordinate: SMACoordinate {
    public var position: Coordinate
    public var fitness: Double
    public var weight: Double
    public let id = String.uid
}

public struct SMA<Coordinate> where Coordinate: SMACoordinate {
    public var population: [Cell<Coordinate>]
    public let space: ClosedRange<Coordinate>
    public let maxIterations: Int
    let fitnessEvaluation: (Coordinate) -> Double
    let z: Double
    public var globalBest: Cell<Coordinate>?
    public var evaluations = 0
    
    var currentBest: Cell<Coordinate> {
        population.first!
    }
    var currentWorst: Cell<Coordinate> {
        population.last!
    }
    /// Initialize a new algorithm
    /// - Parameters:
    ///   - populationSize: Number of cells searching for food. Will greatly effect fitness evaluation count.
    ///   - space: The solution space the cells will be constrained to.
    ///   - maxIterations: The number of iterations to perform.
    ///   - fitnessEvaluation: A closure that models the quality of a solution - or in SM terms - how much a cell can smell food.
    ///   - z: A threshold indicating the probability for the population to randomly "forage" as opposed to closing in on potential optima in any given iteration
    public init(
        populationSize: Int,
        space: ClosedRange<Coordinate>,
        maxIterations: Int,
        fitnessEvaluation: @escaping (Coordinate) -> Double,
        z: Double = 0.3
    ) {
        self.population = (0..<populationSize).map { _ in
            Cell(
                position: Coordinate.random(in: space),
                fitness: -1,
                weight: 1
            )
        }
        self.space = space
        self.maxIterations = maxIterations
        self.fitnessEvaluation = fitnessEvaluation
        self.z = z
        self.globalBest = nil
    }
    public mutating func iterate() {
        var i = 1
        while iteration(&i) == true {}
    }
    
//    @discardableResult
    public mutating func iteration(_ iteration: inout Int) -> Bool {
        guard iteration < maxIterations else {
            return false
        }
        defer {
            iteration += 1
        }
        
        containCells()
        
        // Evaluate fitness
        for i in population.indices {
            var cell = population[i]
            evaluations += 1
            cell.fitness = fitnessEvaluation(cell.position)
            if let globalBest = globalBest,
               cell.fitness > globalBest.fitness {
                self.globalBest = cell
            } else if globalBest == nil {
                globalBest = cell
            }
            population[i] = cell
        }
        
        // Sort fitness - current iteration best & worst are accessible via sorted
        population = population.sorted { a, b in
            a.fitness > b.fitness
        }
        
        // Update weights (Fig. 2.5)
        for i in population.indices {
            population[i].weight = w(population[i], index: i)
        }
        
        // A small chance for fully random search improves general exploration in large solution spaces or with smaller populations
        let r = Double.random(in: 0...1)
        if r < z {
            for i in population.indices {
                var cell = population[i]
                cell.position = Coordinate.random(in: space)
                population[i] = cell
            }
        } else {
            let aVibrationAmount = aggressiveVibrationAmount(iteration)
            let lVibrationAmount = linearVibrationAmount(iteration)
            for i in population.indices {
                let aggressiveVibration = Double.random(in: -aVibrationAmount...aVibrationAmount)
                let linearVibration = Double.random(in: -lVibrationAmount...lVibrationAmount)
                let randomCellA = population.randomElement()!
                let randomCellB = population.randomElement()!
                var cell = population[i]
                // p tends towards 0 when cells are more fit - therefore a fit cell is more likely to "exploit"
                // an unfit cell is more likely to explore elsewhere
                //
                // these work in tandem. without the possibility of exploration cells will get stuck on local optima
                let exploreOrExploit = Double.random(in: 0...1)
                let exploreValue = chanceToExplore(cell)
                
                if exploreOrExploit > exploreValue {
                    
                    // explore
                    cell.position = cell.position + Coordinate(linearVibration) * ((space.upperBound - space.lowerBound) / Coordinate(100.0))
                    
                    // the original implementation tends towards zero too much. why search the origin so much?
//                     cell.position = Coordinate(linearVibration) * cell.position
                    assert(!cell.position.isNaN)
                } else {
                    
                    // exploit
                    // Aggressive vibration is suitable here because it is much less likely that we are near global optima early in the algorithm
                    cell.position = globalBest!.position + Coordinate(aggressiveVibration) * (Coordinate(cell.weight) * randomCellA.position - randomCellB.position)
                    assert(!cell.position.isNaN)
                }
                population[i] = cell
            }
        }
        
        containCells()
        
        return true
    }
    
    /// simulates oscillation in mold based on a cell's fitness relative to the population
    /// higher relative fitness should result in higher allocation of energy for movement
    /// the value returned from this method revolves around 1
    func w(_ cell: Cell<Coordinate>, index: Int) -> Double {
        let r = Double.random(in: 0...1)
        let l = valueRelativeToPopulation(cell)
        if index <= population.count / 2 {
            return 1 + r * l
        } else {
            return 1 - r * l
        }
    }
    
    /// inverse hyperbolic tangent curve from .infinity to zero at max iteration
    func aggressiveVibrationAmount(_ iteration: Int) -> Double {
        Double.atanh(-(Double(iteration) / Double(maxIterations)) + 1)
    }
    
    /// a linear curve from one to zero at max iteration
    func linearVibrationAmount(_ iteration: Int) -> Double {
        1 - (Double(iteration) / Double(maxIterations))
    }
    
    /// a hyperbolic tangent curve from 1 to 0 at best fitness
    /// cells with good fitness are less likely to explore, more likely to exploit nearby
    func chanceToExplore(_ cell: Cell<Coordinate>) -> Double {
        abs(Double.tanh(cell.fitness - currentBest.fitness))
    }
    
    /// logarithmic curve from ~0.3 to zero at best fitness
    func valueRelativeToPopulation(_ cell: Cell<Coordinate>) -> Double {
        let distanceFromBest = currentBest.fitness - cell.fitness
        let populationRange = currentBest.fitness - currentWorst.fitness
        let epsilon = 0.1
        let l = Double.log10((distanceFromBest / (populationRange + epsilon)) + 1)
        assert(!l.isNaN)
        return l
    }
    
    /// keep the mold in the box
    mutating func containCells() {
        for i in population.indices {
            if population[i].position > space.upperBound {
                population[i].position = space.upperBound
            } else if population[i].position < space.lowerBound {
                population[i].position = space.lowerBound
            }
        }
    }
}

private extension String {
    static var uid: Self {
        let characters = "abcdefghijklmnopqrstuvwxyz1234567890".map { String($0) }
        var uid = String()
        for _ in (0..<10) {
            uid.append(characters.randomElement()!)
        }
        return uid
    }
}
