using Mayday
using JuMP
using Base.Test

include("../examples/simple_sos_problem.jl")
test_simple_sos_problem()

include("../examples/simple_sos_problem_convexjl.jl")
test_simple_sos_problem_convexjl()

include("../examples/spotopt_van_der_pol.jl")
test_spotopt_van_der_pol()
test_spotopt_van_der_pol(Mayday.chebyshev_polynomial_first_kind)

include("degrees.jl")
test_variable_degrees()

include("chebyshev.jl")
test_univariate_chebyshev_polynomials_range()
