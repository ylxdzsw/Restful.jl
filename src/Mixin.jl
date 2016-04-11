export hook!, addMixin!

type Mixin
    hooks::Dict{Symbol, Vector{Function}}

    Mixin() = new([i => Function[] for i in HOOKS])
end

hook!(m::Mixin, t::Symbol, f::Function) = hook!(m, t, Function[f])
hook!(m::Mixin, t::Symbol, f::Vector{Function}) = t in HOOKS ? for i in f push!(m.hooks[t], i) end : error("No hook called $t")

addMixin!(r::Resource, m::Mixin) = for (k, v) in m.hooks
    for i in v push!(r.hooks[k], i) end
end
