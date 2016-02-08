module Mayday

using JuMP
import JuMP: getValue
using MultiPoly
import MultiPoly: print, evaluate
import Base: dot
import DataStructures: OrderedDict
export monomials, 
       chebyshev_basis_first_kind,
       generator,
       generators, 
       evaluate,
       deg,
       grad,
       jacobian,
       diff,
       MPoly,
       defPolynomial,
       defSoSPolynomial, 
       addPolynomialEqualityConstraint,
       addSoSConstraint

generators(s::Symbol...) = MultiPoly.generators(MPoly{Float64}, s...)
generator(s::Symbol) = generators(s)[1]

include("basis.jl")

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

grad(poly::MPoly, symbols::Symbol...) = [diff(poly, s) for s in symbols]
jacobian{T}(polys::Vector{MPoly{T}}, symbols::Symbol...) = vcat([grad(poly, symbols...)' for poly in polys]...)

function evaluate{PolyType, ArgType}(polys::Array{MPoly{PolyType}}, args::ArgType...)
    result_type = promote_type(PolyType, ArgType)
    result = Array(result_type, size(polys)...)
    for i = 1:length(polys)
        result[i] = evaluate(polys[i], args...)
    end
    return result
end

function defPolynomial{T}(model::JuMP.Model, variables::Vector{Symbol}, basis::Vector{MPoly{T}})
    @defVar(model, coeffs[1:length(basis)])
    return sum(basis .* coeffs)
end

defPolynomial(model::JuMP.Model, variables::Vector{Symbol}, max_monomial_degree::Integer) = defPolynomial(model, variables, monomials(variables, 0:max_monomial_degree))

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

function getValue{T<:JuMP.GenericAffExpr}(poly::MPoly{T})
    MPoly{Float64}(OrderedDict{Vector{Int}, Float64}(zip(keys(poly.terms), map(getValue, values(poly.terms)))), poly.vars)
end

end
