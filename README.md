# Slime

This is a Swift implementation of a Slime Mold Algorithm generally based on the paper "Slime mould algorithm: A new method for stochastic optimization" by  Li, Shimin; Chen, Huiling; Wang, Mingjing; Heidari, Ali Asghar; Mirjalili, Seyedali

The only dependency required by Slime is `SwiftNumerics`

# Animated Example
Searching for the global maxima of 
`-abs(x + 100000) - abs(y + 100000) + sin(10 * x)`

 <img src="/ex1.gif?raw=true" width="800px">


# More Info
*(from wikiversity)[https://en.wikiversity.org/wiki/Slime_Mould_Algorithm]*

*"Slime mold algorithm (SMA) is a population-based optimization technique which is proposed based on the oscillation style of slime mold in nature. The SMA has a unique mathematical model that simulates positive and negative feedbacks of the propagation wave of slime mold. It has a dynamic structure with a stable balance between global and local search drifts."*

# TODO:
- Readme walkthrough of the math used in the algorithm
- Cool readme
- Explore some deterministic changes
