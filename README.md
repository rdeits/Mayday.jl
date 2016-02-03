# Mayday

A naïve implementation of sums-of-squares (SoS) polynomial optimization through semidefinite programming (SDP). Powered by JuMP and Julia. 

## Requirements

In addition to the packages listed in `REQUIRE`, you'll need an SDP solver with a JuMP interface. Two good options are `SCS.jl` (free software) and `Mosek.jl` (proprietary). Mosek requires a license, but is free for academic use: <https://mosek.com/introduction/buy-mosek>.

[![Build Status](https://travis-ci.org/rdeits/Mayday.jl.svg?branch=master)](https://travis-ci.org/rdeits/Mayday.jl)
