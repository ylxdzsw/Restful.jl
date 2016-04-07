export Resource,
       addmethod,
       addsubresource,
       hook

const METHODS = Symbol[:GET, :POST, :PUT, :PATCH, :DELETE, :COPY, :HEAD, :OPTIONS, :LINK, :UNLINK, :PURGE, :LOCK, :UNLOCK, :PROPFIND, :VIEW]

const HOOKS = Symbol[METHODS; :preroute; :onresponse; :onreturn]

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

function addmethod(r::Resource, t::Symbol, d::AbstractString, f::Function)
    if t in keys(r.methods)
        warn("override $t method of $r.name")
    end
    r.methods[t] = RestMethod(d, f)
end
addmethod(f::Function, r::Resource, t::Symbol, d::AbstractString="$t $r.name") = addmethod(r, t, d, f)

addsubresource(r::Resource, s::Resource) = push!(r.subresources, s)

hook(r::Resource, t::Symbol, f::Function) = t in HOOKS ? push!(r.hooks[t], f) : error("No hook called $t")
