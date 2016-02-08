function variable_degrees{T<:Real}(num_variables::Integer, poly_degrees::AbstractVector{T})
    max_poly_degree = maximum(poly_degrees)
    poly_degrees = Set(poly_degrees)
    all_variable_degrees = Vector{Int}[]
    var_degrees = zeros(Int, num_variables)
    total = 0
    while var_degrees[1] <= max_poly_degree
        if in(total, poly_degrees)
            push!(all_variable_degrees, copy(var_degrees))
        end
        var_degrees[end] += 1
        total += 1
        for j = length(var_degrees):-1:2
            if var_degrees[j] > max_poly_degree || total > max_poly_degree
                total -= var_degrees[j] - 1
                var_degrees[j] = 0
                var_degrees[j-1] += 1
            else
                break
            end
        end
    end
    return all_variable_degrees
end

function monomial(variable::Symbol, degree::Integer)
    MPoly{Float64}(OrderedDict([degree]=>1.0), [variable])
end

function chebyshev_polynomial_first_kind(variable::Symbol, degree::Integer)
    x = generator(variable)
    @assert degree >= 0
    if degree == 0
        return 1 + 0 * x
    elseif degree == 1
        return x
    else
        return (2x * chebyshev_polynomial_first_kind(variable, degree - 1)
                - chebyshev_polynomial_first_kind(variable, degree - 2))
    end
end

function polynomial_basis(variables, degrees=0:2, generator::Function=monomial)
    map(d -> prod(map(i -> generator(variables[i], d[i]), 
                  1:length(variables))), 
        variable_degrees(length(variables), degrees))
end

monomials(variables, degrees=0:2) = polynomial_basis(variables, degrees, monomial)
chebyshev_basis_first_kind(variables, degrees=0:2) = polynomial_basis(variables, degrees, chebyshev_polynomial_first_kind)
