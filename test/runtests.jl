using Mayday
using JuMP
using Base.Test

include("simple_sos_problem.jl")
test_simple_sos_problem()

include("spotopt_van_der_pol.jl")
test_spotopt_van_der_pol()

