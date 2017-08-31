module EvolutionaryAlgorithm

abstract Individual

type Population{T <: Individual}
	individuals	::Vector{T}
	generation	::Int
	function Population(pop_size::Int, genotype_size::Int)
		t=Vector{T}(pop_size)
		for i=1:pop_size
			t[i]=T(genotype_size)
		end
		return new(t, 1)
	end
	function Population(pop_size::Int, genotype_size::Int, r::OrdinalRange)
		t=Vector{T}(pop_size)
		for i=1:pop_size
			t[i]=T(genotype_size, r)
		end
		return new(t, 1)
	end
end

type StringIndividual{T} <: Individual
	genotype	::Vector{T}
	#phenotype	::AbstractString
	fitness		::Float64

	StringIndividual(x) = new(x, -1.0)

	StringIndividual(l::Int) = new(rand(T, l), -1.0)

	StringIndividual(l::Int, r::OrdinalRange) = new(rand(r, l), -1.0)
end

import Base.string
function string{T}(x::StringIndividual{T})
    return string(x.genotype)
end

function string{T <: Unsigned}(x::StringIndividual{T})
    return string(round(Int, x.genotype))
end

import Base.print
print(io::IO, x::Individual) = print(io, string(x))
import Base.show
show(io::IO, x::Individual) = print(io, x)
import Base.isless
isless(a::StringIndividual, b::StringIndividual) = a.fitness < b.fitness

export StringIndividual, Population,
	evolution, best_individual, worst_individual, get_best_fitness, get_worst_fitness, get_fitness_array

function best_individual(pop::Population)
	return maximum(pop.individuals)
end

function worst_individual(pop::Population)
	return minimum(pop.individuals)
end

function get_best_fitness(pop::Population)
	return maximum(get_fitness_array(pop))
end

function get_worst_fitness(pop::Population)
	return minimum(get_fitness_array(pop))
end

function get_fitness_array(pop::Population)
	return map(x-> x.fitness, pop.individuals)
end

function replace_individuals!(pop1::Vector, pop2::Vector)
	sort!(pop1)
	sort!(pop2)
	j = 1
	for i in pop2
		if pop1[j] >= i
			pop1[j] = i
			j += 1
		end
	end
	nothing
end
function elitism!(pop1::Vector, pop2::Vector, n::Int)
	sort!(pop1, rev=true)
	sort!(pop2, rev=true)
	pop1[1+n:end] = pop2[1:end-n]
	nothing
end

function gen_pop_result{T}(individuals::Vector{StringIndividual{T}}, fitness_function::Function)
	fits = pmap(fitness_function, individuals)
	for i = 1:endof(individuals)
		individuals[i].fitness = fits[i]
		#	individuals[i].fitness = 1 - (tp/(tp+fn)+tn/(tn+fp) - 1) #j statistic inverse
	end
end

function evolution(
			pop			::Population,
			ffunction		::Function,
			selection		::Function,
			mutation		::Function=(x->x),
			crossover		::Function=((x, y)->(x, y)),
			max_generations	::Int=10,
			optimal_fitness	::Float64=1.0
			)

	population_pool = Population[]
	gen_pop_result(pop.individuals, ffunction)
	push!(population_pool, deepcopy(pop))

	pop_size=endof(pop.individuals)
	selected = similar(pop.individuals)
	while get_best_fitness(pop) <= optimal_fitness && pop.generation < max_generations
		for i=1:pop_size
			selected[i] = selection(pop)
		end
		for i=2:2:pop_size
			selected[i-1], selected[i] = crossover(selected[i-1], selected[i])
		end
		for i in selected
			mutation(i)
		end
		pop.generation += 1
		gen_pop_result(pop.individuals, ffunction)
		push!(population_pool, deepcopy(pop))
		elitism!(pop.individuals, selected, 5)
	end
	population_pool
end
end
