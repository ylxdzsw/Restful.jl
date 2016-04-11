export Resource,
       addmethod!,
       addsubresource!,
       hook!

type Resource
    name::AbstractString
    route::Union{AbstractString, Function}
    methods::Dict{Symbol, RestMethod}
    subresources::Vector{Resource}
    hooks::Dict{Symbol, Vector{Function}}

    Resource(name::AbstractString = "";
             route::Union{AbstractString, Function} = name,
             methods::Dict{Symbol, RestMethod} = Dict{Symbol, RestMethod}(),
             subresources::Vector{Resource} = Resource[],
             hooks::Dict{Symbol, Vector{Function}} = [i => Function[] for i in HOOKS]) =
        new(name, route, methods, subresources, hooks)
end

function addmethod!(r::Resource, t::Symbol, d::AbstractString, f::Function)
    if t in keys(r.methods)
        warn("override $t method of $r.name")
    end
    if t in METHODS
        r.methods[t] = RestMethod(d, f)
    else
        error("no method called $t")
    end
end
addmethod!(f::Function, r::Resource, t::Symbol, d::AbstractString="$t $r.name") = addmethod!(r, t, d, f)

addsubresource!(r::Resource, s::Resource) = push!(r.subresources, s)
addsubresource!(r::Resource, s::Vector{Resource}) = for i in s addsubresource!(r, i) end

hook!(r::Resource, t::Symbol, f::Function) = hook!(r, t, Function[f])
hook!(r::Resource, t::Symbol, f::Vector{Function}) = t in HOOKS ? for i in f push!(r.hooks[t], i) end : error("No hook called $t")

HttpServer.Server(r::Resource) = HttpHandler((req, _) -> r(req)) |> Server
