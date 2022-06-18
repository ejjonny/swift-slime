import Numerics

public struct Slime<V: Vector> {
    public struct Cell: Equatable {
        public var position: V
        public var fitness: Double
        public var weight: Double
        public var id = String.uid
    }
    public struct MetaData {
        public var history = [Cell]()
        public init() {}
    }
    public enum Method {
        case minimize
        case maximize
    }
    public var population: [Cell]
    public let lower: V
    public let upper: V
    public let maxIterations: Int
    let fitnessEvaluation: (V) -> Double
    let z: Double
    let method: Method
    let bestCount: Int
    let problemSize: Int
    /// The best solutions discovered - populated when iterations are completed
    public var bestCells = [Cell]()
    public var evaluations = 0
    
    public var metaData: MetaData?
    
    var best: Cell {
        bestCells.first!
    }
    var currentBest: Cell {
        population.first!
    }
    var currentWorst: Cell {
        population.last!
    }
    
    /// Initialize a Slime algorithm object
    /// - Parameters:
    ///   - populationSize: Number of searching "cells". Evaluation count will be up to `maxIterations x populationSize`
    ///   - maxIterations: Number of iterations before the algorithm will finish
    ///   - lower: Vector representing lower bound of solution space.
    ///   - upper: Vector representing upper bound of solution space. Vector component count must match lowerBound
    ///   - z: A threshold in [0, 1] indicating the probability for the population to fully randomize their positions on any given iteration. This can improve searches in large search spaces / with small populations
    ///   - method: `.maximize`- higher fitness numbers are better vs. `.minimize` - lower fitness values are better
    ///   - bestCount: The size of the list of candidates with good fitness
    ///   - metaData: An object to track things like search history if needed
    ///   - fitnessEvaluation: A closure returning the fitness for an individual solution
    public init(
        populationSize: Int,
        maxIterations: Int,
        lower: V,
        upper: V,
        z: Double = 0.3,
        method: Method = .maximize,
        bestCount: Int = 3,
        metaData: MetaData? = nil,
        fitnessEvaluation: @escaping (V) -> Double
    ) {
        self.population = (0..<populationSize).map { _ in
            Cell(
                position: V.random(lower: lower, upper: upper),
                fitness: -1,
                weight: 1
            )
        }
        self.lower = lower
        self.upper = upper
        self.maxIterations = maxIterations
        self.fitnessEvaluation = fitnessEvaluation
        self.z = z
        self.method = method
        self.bestCount = bestCount
        self.problemSize = lower.scalarCount
        self.metaData = metaData
    }
    
    /// Run the search up to max iterations
    public mutating func run() {
        var i = 1
        while iterateOnce(&i) == true {}
    }
    
    @discardableResult
    /// Run a single iteration
    /// - Parameter iteration: Iteration counter. This shouldn't be modified by the caller right now - if it is I don't know what to expect.
    /// - Returns: A boolean indicating whether there are iterations left to perform
    public mutating func iterateOnce(_ iteration: inout Int) -> Bool {
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
            
            switch method {
            case .minimize:
                cell.fitness = -fitnessEvaluation(cell.position)
            case .maximize:
                cell.fitness = fitnessEvaluation(cell.position)
            }
            
            // Update best
            if bestCells.isEmpty {
                bestCells.append(cell)
            }
            
            for i in bestCells.indices {
                let best = bestCells[i]
                if cell.fitness > best.fitness {
                    bestCells.insert(cell, at: i)
                }
                bestCells = Array(bestCells.prefix(bestCount))
            }

            population[i] = cell
        }
        
        // Sort fitness - current iteration best & worst are accessible via sorted
        population = population.sorted { a, b in
            a.fitness >  b.fitness
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
                cell.position = V.random(lower: lower, upper: upper)
                population[i] = cell
            }
        } else {
            let aVibrationAmount = aggressiveVibrationAmount(iteration)
            let lVibrationAmount = linearVibrationAmount(iteration)
            for i in population.indices {
                var cell = population[i]
                // p tends towards 0 when cells are more fit - therefore a fit cell is more likely to "exploit"
                // an unfit cell is more likely to explore elsewhere
                //
                // these work in tandem. without the possibility of exploration cells will get stuck on local optima
                let exploreOrExploit = Double.random(in: 0...1)
                let exploreValue = chanceToExplore(cell)
                
                if exploreOrExploit > exploreValue {
                    // explore
                    // Vibrate using a random percentage of one 100th of the search space
                    cell.position = cell.position + V.random(in: -lVibrationAmount...lVibrationAmount) * ((upper - lower) / 100.0)
                } else {
                    // exploit
                    // Aggressive initial vibration is suitable here because it is much less likely that we are near global optima early in the algorithm
                    let rpos = population[Int.random(in: population.indices)].position - population[Int.random(in: population.indices)].position
                    cell.position = best.position + V.random(in: -aVibrationAmount...aVibrationAmount) * (V.Scalar(cell.weight) * rpos)
                }
                population[i] = cell
            }
        }
        
        containCells()
        
        if metaData != nil {
            recordMetaData()
        }
        
        return true
    }
    
    /// simulates oscillation in mold based on a cell's fitness relative to the population
    /// higher relative fitness should result in higher allocation of energy for movement
    /// the value returned from this method revolves around 1
    func w(_ cell: Cell, index: Int) -> Double {
        let r = Double.random(in: 0...1)
        let l = valueRelativeToPopulation(cell)
        if index <= population.count / 2 {
            return 1 + r * l
        } else {
            return 1 - r * l
        }
    }
    
    /// inverse hyperbolic tangent curve from .infinity to zero at max iteration
    func aggressiveVibrationAmount(_ iteration: Int) -> V.Scalar {
        V.Scalar(Double.atanh(-(Double(iteration) / Double(maxIterations)) + 1))
    }
    
    /// a linear curve from one to zero at max iteration
    func linearVibrationAmount(_ iteration: Int) -> V.Scalar {
        1 - (V.Scalar(iteration) / V.Scalar(maxIterations))
    }
    
    /// a hyperbolic tangent curve from 1 to 0 at best fitness
    /// cells with good fitness are less likely to explore, more likely to exploit nearby
    func chanceToExplore(_ cell: Cell) -> Double {
        abs(Double.tanh(cell.fitness - currentBest.fitness))
    }
    
    /// logarithmic curve from ~0.3 to zero at best fitness
    func valueRelativeToPopulation(_ cell: Cell) -> Double {
        let distanceFromBest = currentBest.fitness - cell.fitness
        let populationRange = currentBest.fitness - currentWorst.fitness
        let epsilon = 0.1
        let l = Double.log10((distanceFromBest / (populationRange + epsilon)) + 1)
        assert(!l.isNaN)
        return l
    }
    
    /// keep the mold in the box
    mutating func containCells() {
        for cellIndex in population.indices {
            var cell = population[cellIndex]
            cell.position.clamp(lowerBound: lower, upperBound: upper)
            population[cellIndex] = cell
        }
    }
    
    mutating func recordMetaData() {
        let unique: [Cell] = population.indices.compactMap {
            var cell = population[$0]
            cell.id = String.uid
            return cell
        }
        metaData?.history.append(contentsOf: unique)
    }
}
