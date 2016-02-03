module Mayday

using JuMP
using MultiPoly
import MultiPoly: print
import Base: dot
import DataStructures: OrderedDict
export monomials, 
	   generator,
	   generators, 
	   evaluate,
	   defSoSPolynomial, 
	   addPolynomialEqualityConstraint,
	   addSoSConstraint

generators(s::Symbol...) = MultiPoly.generators(MPoly{Float64}, s...)
generator(s::Symbol) = generators(s)[1]

function print{T<:JuMP.GenericAffExpr}(io::IO, p::MPoly{T})
    first = true
    for (m, c) in p
        if first
            print(io, c)
            MultiPoly.printmonomial(io, m, vars(p))
            first = false
        else
            print(io, " + ($c)")
            MultiPoly.printmonomial(io, m, vars(p))
        end
    end
    if first
        print(io, zero(T))
    end
end

function monomials(variables, degrees=0:2)
    sort!(degrees)
    monomials = Array(MPoly{Float64}, 0)
    powers = zeros(Int64, length(variables))
    total = 0
    terms = OrderedDict(powers=>1.0)
    while powers[1] <= degrees[end]
        for d = degrees
            if total == d
            	push!(monomials, MPoly{Float64}(terms, variables))
                break
            end
        end
        powers[end] += 1
        total += 1
        for j = length(powers):-1:2
            if powers[j] > degrees[end] || total > degrees[end]
                total -= (powers[j] - 1)
                powers[j] = 0
                powers[j-1] += 1
            else
                break
            end
        end
    end
    return monomials
end

dot(x::Number, y::MPoly) = x * y
dot(x::MPoly, y::Number) = x * y
dot(x::MPoly, y::JuMP.GenericAffExpr) = x*y
dot(x::JuMP.GenericAffExpr, y::MPoly) = x*y

function defSoSPolynomial{T}(model::JuMP.Model, variables::Vector{Symbol}, basis::Vector{MPoly{T}})
    @defVar(model, Q[1:length(basis), 1:length(basis)], SDP)
    return sum(sum(basis .* Q, 1)' .* basis)
end

defSoSPolynomial(model::JuMP.Model, variables::Vector{Symbol}, max_monomial_degree::Integer) = defSoSPolynomial(model, variables, monomials(variables, 0:max_monomial_degree))

function addPolynomialEqualityConstraint(model::JuMP.Model, poly1::MPoly, poly2::MPoly)
    @assert poly1.vars == poly2.vars
    constrained_powers = []
    for (powers, coefficient) in poly1
        @addConstraint(model, poly2[powers] == coefficient)
        push!(constrained_powers, powers)
    end
    for (powers, coefficient) in poly2
        if !in(powers, constrained_powers)
            @addConstraint(model, poly1[powers] == coefficient)
        end
    end
end

function addSoSConstraint(model, poly)
    max_degree = maximum([maximum(x) for x in keys(poly.terms)])
    sos_poly = defSoSPolynomial(model, poly.vars, max_degree)
    addPolynomialEqualityConstraint(model, sos_poly, poly)
end

end
