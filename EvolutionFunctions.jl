function multipoint_crossover(n_segments::Int=1, chance::Float64=0.8)
	n_segments <= 0 && error("Segment number must be positive")
	chance <= 0 && error("Crossover chance must be positive")
	function crossover{T}(parent_a::StringIndividual{T}, parent_b::StringIndividual{T})
		gen_offspring1 = copy(parent_a.genotype)
		gen_offspring2 = copy(parent_b.genotype)
		if rand() <= chance
			l = endof(gen_offspring1)

			segments = sort(unique([rand(2:l-1, n_segments);l]))

			n = endof(segments)
			if isodd(endof(segments))
				n = n-1
			end

			for i=2:2:n
				swap_range = segments[i-1]+1:segments[i]
				gen_offspring1[swap_range], gen_offspring2[swap_range] = gen_offspring2[swap_range], gen_offspring1[swap_range]
			end
		end
		return StringIndividual{T}(gen_offspring1), StringIndividual{T}(gen_offspring2)
	end
end

function uniform_crossover(chance::Float64=0.8)
	chance <= 0 && error("Crossover chance must be positive")
	function crossover{T}(parent_a::StringIndividual{T}, parent_b::StringIndividual{T})
		gen_offspring1 = deepcopy(parent_a.genotype)
		gen_offspring2 = deepcopy(parent_b.genotype)
		if rand() <= chance
			l = endof(gen_offspring1)

			mask = bitrand(l)
			indexes = find(mask)

			tmp_var = 0
			for i in indexes
				tmp_var = gen_offspring1[i]
				gen_offspring1[i] = gen_offspring2[i]
				gen_offspring2[i] = tmp_var
			end
		end

		return StringIndividual{T}(gen_offspring1), StringIndividual{T}(gen_offspring2)
	end
end

#function arithmetic_crossover{T <: AbstractFloat}(parent_a::StringIndividual{T}, parent_b::StringIndividual{T})
#	gen_offspring = (parent_a.genotype+parent_b.genotype)/2
#
#	return StringIndividual{T}(gen_offspring), StringIndividual{T}(gen_offspring)
#end

function mutation_factory(chance::Float64=0.25, ratio::Float64=0.02)
	ratio <= 0.0 && error("Mutation ratio must be positive")
	chance <= 0 && error("Mutation chance must be positive")
	function mutation!{T}(ind::StringIndividual{T})
		if rand() <= chance
			l = endof(ind.genotype)
			indexes = find(x-> x <= ratio, rand(Float16, l))
			for i in indexes
				ind.genotype[i] = rand(T)
			end
		end
	end
	function mutation!{T <: Bool}(ind::StringIndividual{T})
		l = endof(ind.genotype)
		indexes = find(x-> x < ratio, rand(Float16, l))
		ind.genotype[indexes] = ~(ind.genotype[indexes])
		nothing
	end
end

function mutation_factory{T}(r::OrdinalRange{T}, chance::Float64=0.25, ratio::Float64=0.02)
	ratio <= 0.0 && error("Mutation ratio must be positive")
	chance <= 0 && error("Mutation chance must be positive")
	function mutation!(ind::StringIndividual{T})
		if rand() <= chance
			l = endof(ind.genotype)
			indexes = find(x-> x < ratio, rand(Float16, l))
			for i in indexes
				ind.genotype[i] = rand(r)
			end
		end
	end
end

#closest(a::StringIndividual, b::StringIndividual, c::Float64) = a.fitness % c <= b.fitness % c ? a : b

function tournament(size::Int=2)
	size <= 0 && error("Tournament size must be positive")
	function selection(pop::Population)
		pop_size = endof(pop.individuals)
		tournament_candidates = pop.individuals[rand(1:pop_size,size)]
		return maximum(tournament_candidates)
	end
end
