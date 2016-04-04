import Base.call

function Base.call(r::Resource, req::Request)
    req |> parserequest |> r
end

function Base.call(r::Resource, req::Dict{Symbol, Any}, id::AbstractString="/")
    res = callmethod(r, req, id)
    makeresponse(r, res)
end

function route(candidates::Vector{Resource}, req, id)
    ismatch(p::AbstractString) = p == "*" || p == id
    ismatch(p::Function) = p(id)

    i = findfirst(x->ismatch(x.route), candidates)
    if i == 0
        404
    else
        candidates[i](req, id)
    end
end

function parserequest(req::Request)
    uri = URI(req.resource)
    Dict{Symbol, Any}(
        :method  => req.method |> Symbol,
        :headers => req.headers,
        :body    => req.data,
        :path    => uri.path   |> splitpath,
        :query   => uri.query  |> parsequerystring # this should be moved out of Rest.jl. Maybe add a mixin system?
    )
end

splitpath(p::AbstractString) = split(p, '/', keep=false)

function callmethod(r::Resource, req::Dict{Symbol, Any}, id::AbstractString)
    if isempty(req[:path]) # leaf node
        let r = r.methods, v = req[:method]
            haskey(r, v) ? r[v](req, id) : 405
        end
    else
        req[Symbol(r.name * "id")] = id
        route(r.subresources, req, shift!(req[:path]))
    end
end

function makeresponse(r::Resource, res::Response)
    res.headers["Allow"] = join(keys(r.methods), ", ")
    res
end
makeresponse(r::Resource, res) = makeresponse(r, Response(res))

