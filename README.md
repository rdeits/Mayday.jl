# Mayday

[![Build Status](https://travis-ci.org/rdeits/Mayday.jl.svg?branch=master)](https://travis-ci.org/rdeits/Mayday.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/h5n4etw5lir9iu3h?svg=true)](https://ci.appveyor.com/project/rdeits/mayday-jl)
[![codecov.io](https://codecov.io/github/rdeits/Mayday.jl/coverage.svg?branch=master)](https://codecov.io/github/rdeits/Mayday.jl?branch=master)

Mayday.jl is a naïve implementation of sums-of-squares (SoS) polynomial optimization through semidefinite programming (SDP), powered by JuMP and Julia.

SoS programming is used in control theory to search for controllers for a dynamical system (like a robot or airplane) and to find the set of states for which those controllers will be valid. To learn more about how SoS programming is used, check out <http://underactuated.csail.mit.edu/underactuated.html?chapter=11>

## Requirements

To use this package, you'll need an SDP solver with a JuMP interface. If you installed Mayday with `Pkg.add()`, then you've already gotten `SCS.jl`, a wrapper for the free SCS solver, and you're all set. You may also want to install Mosek, a proprietary solver, with `Pkg.add("Mosek")`. Mosek requires a license, but is free for academic use: <https://mosek.com/introduction/buy-mosek> and is generally faster.

## Usage

Check out the `examples` folder for demonstrations.
