using JuMP
using Mayday

function test_simple_sos_problem()
	# Let's find a polynomial which is > 1 for x < -1 and < -1 for x > 1
	# v(x) + d1(x) * (x + 1) is SOS
	# -v(x) + d2(x) * (1 - x) is SOS
	# d1(x) is SOS
	# d2(x) is SOS

	m = Model()
	degree = 4
	x = generator(:x)
	monos = monomials([:x], 0:degree)
	@defVar(m, coeffs[1:length(monos)])
	v = sum(coeffs .* monos)
	@show v
	d1 = defSoSPolynomial(m, [:x], degree / 2)
	d2 = defSoSPolynomial(m, [:x], degree / 2)
	addSoSConstraint(m, (v - 1) + d1 * (x + 1))
	addSoSConstraint(m, -(v + 1) + d2 * (1 - x))
	solve(m)

	# Extract the result:
	poly = sum(map(getValue, coeffs) .* monos)
	@show poly

	# Verify it:
	x = linspace(-2, 2)
	y = map(x -> evaluate(poly, x), x)

	for i = 1:length(x)
		if x[i] < -1
			@test y[i] >= 1
		elseif x[i] > 1
			@test y[i] <= -1
		end
	end
end
