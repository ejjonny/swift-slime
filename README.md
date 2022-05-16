# Slime

This is a Swift implementation of a Slime Mold Algorithm - a stochastic optimizer - generally based on this [paper](https://doi.org/10.1016/j.future.2020.03.055)

The only dependency required by Slime is `SwiftNumerics`

# Visual Examples
Searching for the global maxima of 
`-abs(x + 100000) - abs(y + 100000) + sin(10 * x)`

 <img src="/ex1.gif?raw=true" width="500px">
 
Searching for the shortest path visiting 50 locations (traveling salesman)

 <img src="/ex2.gif?raw=true" width="500px">

# Use the Slime

In a SwiftPM project:

Add the following line to the dependencies in your Package.swift file:

```swift
.package(url: "https://github.com/ejjonny/slime", from: "1.0.0"),
```

Add Slime as a dependency for your target:

```swift
.target(
    name: "MyTarget", 
    dependencies: [
        .product(name: "Slime", package: "Slime"),
    ]
),
```

Add `import Slime` to your swift file.

```swift
var slime = Slime(
                populationSize: 10,
                maxIterations: 100,
                lowerBound: [-1, -1],
                upperBound: [1, 1],
                method: .minimize, // Use .maximize if higher fitness values are better
                fitnessEvaluation: { vector in
                    let x = vector[0]
                    let y = vector[1]
                    // Return a fitness value Double using the proposed vector
                }
            )
slime.run() // This runs the fitness evaluation many times, among other busy work, & will usually be expensive

slime.bestCells // An array of the top 3 Cells. Use Cell.position for the associated vectors
```

This example is using a 2 dimensional solution space. The algorithm will work with any number of vector components if you're looking for a solution in *hyperspace*.

# More Info

*[wikiversity](https://en.wikiversity.org/wiki/Slime_Mould_Algorithm)*
> *"Slime mold algorithm (SMA) is a population-based optimization technique which is proposed based on the oscillation style of slime mold in nature. The SMA has a unique mathematical model that simulates positive and negative feedbacks of the propagation wave of slime mold. It has a dynamic structure with a stable balance between global and local search drifts."*

# TODO:

- Readme walkthrough of the math used in the algorithm
- Explore some deterministic changes
