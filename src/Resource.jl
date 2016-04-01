export Resource,
       addmethod,
       addsubresource

type Resource
    name::AbstractString
    route::Union{AbstractString, Function}
    methods::Dict{Symbol, RestMethod}
    subresources::Vector{Resource}

    Resource(name::AbstractString = "";
             route::Union{AbstractString, Function} = name,
             methods::Dict{Symbol, RestMethod} = Dict{Symbol, RestMethod}(),
             subresources::Vector{Resource} = Vector{Resource}()) =
        new(name, route, methods, subresources)
end

function addmethod(r::Resource, t::Symbol, d::AbstractString, f::Function)
    if t in keys(r.methods)
        warn("override $t method of $r.name")
    end
    r.methods[t] = RestMethod(d, f)
end
addmethod(f::Function, r::Resource, t::Symbol, d::AbstractString="$t $r.name") = addmethod(r, t, d, f)

addsubresource(r::Resource, s::Resource) = push!(r.subresources, s)
