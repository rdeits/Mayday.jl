using JuMP
using Mayday
using Base.Test
using SCS

function test_simple_sos_problem()
	# Let's find a polynomial which is > 1 for x < -1 and < -1 for x > 1
	# v(x) + d1(x) * (x + 1) - 1 is SOS
	# -v(x) + d2(x) * (1 - x) - 1 is SOS
	# d1(x) is SOS
	# d2(x) is SOS

	model = Model(solver=SCSSolver())
	degree = 4
	v = defPolynomial(model, [:x], degree)
	@show v
	d1 = defSoSPolynomial(model, [:x], degree / 2)
	d2 = defSoSPolynomial(model, [:x], degree / 2)
	x = generator(:x)
	addSoSConstraint(model, v + d1 * (x + 1) - 1)
	addSoSConstraint(model, -v + d2 * (1 - x) - 1)
	solve(model)

	# Extract the result:
	v = getvalue(v)
	@show v

	# Verify it:
	x = linspace(-2, 2)
	y = map(x -> evaluate(v, x), x)

	for i = 1:length(x)
		if x[i] < -1
			@test y[i] >= 1
		elseif x[i] > 1
			@test y[i] <= -1
		end
	end
end

test_simple_sos_problem()
