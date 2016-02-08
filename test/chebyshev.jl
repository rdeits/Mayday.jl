function test_univariate_chebyshev_polynomials_range()
	chebyshev_polys = chebyshev_basis_first_kind([:x], 0:5)
	x = linspace(-1, 1)
	for poly in chebyshev_polys
	    y = map(x -> evaluate(poly, x), x)
	    @test maximum(y) <= 1
	    @test minimum(y) >= -1
	end
end

