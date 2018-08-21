export hook!, addmixin!

mutable struct Mixin
    hooks::Dict{Symbol, Vector{Function}}

    Mixin() = new(Dict(i => Function[] for i in HOOKS))
end

hook!(m::Mixin, t::Symbol, f::Function) = hook!(m, t, Function[f])
hook!(m::Mixin, t::Symbol, f::Vector{Function}) = t in HOOKS ? for i in f push!(m.hooks[t], i) end : error("No hook called $t")

addmixin!(r::Resource, m::Mixin) = addmixin!(r, Mixin[m])
addmixin!(r::Resource, ms::Vector{Mixin}) = for m in ms
    for (k, v) in m.hooks
        for i in v push!(r.hooks[k], i) end
    end
end
