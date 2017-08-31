
module GrammaticalEvolution

export WrapException, generate_program_body, Grammar

type WrapException <: Exception end

typealias Grammar Dict{AbstractString, Vector{AbstractString}}

function parser_factory(gen::Vector, grammar::Grammar, wrap::Bool, maxwrap::Int)
	i=start(gen)
	wraps=1
	function parser(symb::AbstractString)
		x=0
		if !done(gen, i)
			x, i = next(gen, i)
		elseif wraps <= maxwrap && wrap
			wraps += 1
			i=start(gen)
      x, i = next(gen, i)
      else
      	return"*erro*"
		end
		y=endof(grammar[symb])
		idx = mod(Int(x), y) + 1
		return grammar[symb][idx]
	end
end

function generate_program_body(gen::Vector, start_string::AbstractString, error_string::AbstractString, grammar::Grammar, wrap::Bool, maxwrap::Int)
	a=r"<[a-z0-9]+>"i
	s=start_string
	r=parser_factory(gen, grammar, wrap, maxwrap)
	while ismatch(a, s)
		s=replace(s, a, r, 1)
	end
	if contains(s, "*erro*")
		s = error_string
	end
	return s
end
end
