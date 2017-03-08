using JuMP
using Mayday
using Base.Test
using SCS

function test_spotopt_van_der_pol(basis_generator=Mayday.monomial)
	# Replicates the test from https://github.com/spot-toolbox/spotless/blob/master/spotopt/tests/example_vanDerPol.m
	# which maximizes the verified Region of Attraction of a linear controller
	# for the van der Pol oscillator about the origin.

	x, y = generators(:x, :y)

	# System dynamics:
	f = -[y; (1 - x^2) * y - x]

	# Construct a Lyapunov function
	J = jacobian(f, :x, :y)
	A = evaluate(J, 0.0, 0.0)
	P = lyap(A', eye(2,2))
	V = Mayday.quad([x; y], P)
	Vdot = sum(grad(V, :x, :y) .* f)

	# Solve for the maximum RoA, parameterized by rho
	model = Model(solver=SCSSolver())
	@variable(model, rho)
	lambda = defPolynomial(model, [:x, :y], 4, basis_generator)
	d = Int(floor(deg(lambda * Vdot) / 2 - 1))
	addSoSConstraint(model, lambda * Vdot + (V - rho) * (x^2 + y^2)^d, basis_generator)
	@objective(model, Max, rho)
	solve(model)

	result = getvalue(rho)
	@show result

	# Verify rho against the answer we get from spotless
	@test abs(result - 2.3045) < 1e-3
end

test_spotopt_van_der_pol()
