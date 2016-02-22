using JuMP
using Mayday

function test_simple_sos_problem()
	# Let's find a polynomial which is > 1 for x < -1 and < -1 for x > 1
	# v(x) + d1(x) * (x + 1) is SOS
	# -v(x) + d2(x) * (1 - x) is SOS
	# d1(x) is SOS
	# d2(x) is SOS

	model = Model()
	degree = 4
	v = defPolynomial(model, [:x], degree)
	@show v
	d1 = defSoSPolynomial(model, [:x], degree / 2)
	d2 = defSoSPolynomial(model, [:x], degree / 2)
	x = generator(:x)
	addSoSConstraint(model, (v - 1) + d1 * (x + 1))
	addSoSConstraint(model, -(v + 1) + d2 * (1 - x))
	solve(model)

	# Extract the result:
	v = getValue(v)
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
