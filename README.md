# Mayday

[![Build Status](https://travis-ci.org/rdeits/Mayday.jl.svg?branch=master)](https://travis-ci.org/rdeits/Mayday.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/h5n4etw5lir9iu3h?svg=true)](https://ci.appveyor.com/project/rdeits/mayday-jl)

A naïve implementation of sums-of-squares (SoS) polynomial optimization through semidefinite programming (SDP). Powered by JuMP and Julia. 

## Requirements

To use this package, you'll need an SDP solver with a JuMP interface. If you installed Mayday with `Pkg.add()`, then you've already gotten `SCS.jl`, a wrapper for the free SCS solver, and you're all set. You can also choose to install the `Mosek.jl` package if you want to use  Mosek, a proprietary solver. Mosek requires a license, but is free for academic use: <https://mosek.com/introduction/buy-mosek> and is generally faster. 
