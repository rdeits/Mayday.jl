__precompile__()
module Mayday

using JuMP
import JuMP: getvalue
using MultiPoly
import MultiPoly: print, evaluate
import DataStructures: OrderedDict
export monomials,
       chebyshev_basis_first_kind,
       polynomial_basis,
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
jacobian{T}(polys::Vector{MPoly{T}}, symbols::Symbol...) = permutedims(hcat([grad(poly, symbols...) for poly in polys]...), [2 1])

function evaluate{PolyType, ArgType}(polys::Array{MPoly{PolyType}}, args::ArgType...)
    result_type = promote_type(PolyType, ArgType)
    result = Array(result_type, size(polys)...)
    for i = 1:length(polys)
        result[i] = evaluate(polys[i], args...)
    end
    return result
end

function defPolynomial{T}(model::JuMP.Model, variables::Vector{Symbol}, basis::Vector{MPoly{T}})
    coeffs = @variable(model, [1:length(basis)], basename="coeff")
    return sum(basis .* coeffs)
end

defPolynomial(model::JuMP.Model, variables::Vector{Symbol}, max_monomial_degree::Integer, basis_generator::Function=monomial) = defPolynomial(model, variables, polynomial_basis(variables, 0:max_monomial_degree, basis_generator))

function quad{Tx, TQ, Ty}(x::AbstractVector{Tx}, Q::AbstractMatrix{TQ}, y::AbstractVector{Ty})
    result = zero(promote_type(Tx, promote_type(TQ, Ty)))
    for (i, xi) in enumerate(x)
        for (j, yj) in enumerate(y)
            result += xi * Q[i,j] * yj
        end
    end
    result
end
quad(x::AbstractVector, Q::AbstractMatrix) = quad(x, Q, x)

function defSoSPolynomial{T}(model::JuMP.Model, variables::Vector{Symbol}, basis::Vector{MPoly{T}})
    Q = @variable(model, [1:length(basis), 1:length(basis)], basename="Q")
    @SDconstraint(model, Q >= 0)
    quad(basis, Q)
end

defSoSPolynomial(model::JuMP.Model, variables::Vector{Symbol}, max_monomial_degree::Real, basis_generator::Function=monomial) = defSoSPolynomial(model, variables, polynomial_basis(variables, 0:max_monomial_degree, basis_generator))

function addPolynomialEqualityConstraint(model::JuMP.Model, poly1::MPoly, poly2::MPoly)
    @assert poly1.vars == poly2.vars
    constrained_powers = []
    for (powers, coefficient) in poly1
        @constraint(model, poly2[powers] == coefficient)
        push!(constrained_powers, powers)
    end
    for (powers, coefficient) in poly2
        if !in(powers, constrained_powers)
            @constraint(model, poly1[powers] == coefficient)
        end
    end
end

function addSoSConstraint(model, poly, basis_generator::Function=monomial)
    max_degree = maximum([maximum(x) for x in keys(poly.terms)])
    basis = polynomial_basis(poly.vars, 0:Int(ceil(max_degree / 2)), basis_generator)
    addSoSConstraint(model, poly, basis)
end

function addSoSConstraint{T}(model, poly, basis::AbstractVector{MPoly{T}})
    sos_poly = defSoSPolynomial(model, poly.vars, basis)
    addPolynomialEqualityConstraint(model, sos_poly, poly)
end

function getvalue{T<:JuMP.GenericAffExpr}(poly::MPoly{T})
    MPoly{Float64}(OrderedDict{Vector{Int}, Float64}(zip(keys(poly.terms), map(getvalue, values(poly.terms)))), poly.vars)
end

end
