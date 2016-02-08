function test_variable_degrees()
	for num_vars = 1:10
		for min_degree = 0:3
			for max_degree = 3:5
				degrees = shuffle(collect(min_degree:max_degree))
				for d in Mayday.variable_degrees(num_vars, degrees)
					@test length(d) == num_vars
					@test sum(d) >= min_degree
					@test sum(d) <= max_degree
				end
			end
		end
	end
end
