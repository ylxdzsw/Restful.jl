macro callhook4(hook, r, req, id)
    r, req, id = map(esc, (r, req, id))
    quote
        for f! in $r.hooks[$hook]
            result = f!($r, $req, $id)
            if isa(result, Dict{Symbol, Any})
                $req = result
            elseif isa(result, Response)
                return result
            end
        end
    end
end

macro callhook5(hook, r, req, id, res)
    r, req, id, res = map(esc, (r, req, id, res))
    quote
        for f! in $r.hooks[$hook]
            result = f!($r, $req, $id, $res)
            if isa(result, Response)
                $res = result
            end
        end
        $res
    end
end

(r::Resource)(req::Request) = req |> parserequest |> r

function (r::Resource)(req::Dict{Symbol, Any}, id::AbstractString="/")
    @callhook4(:onroute, r, req, id)
    res = if isempty(req[:path]) # leaf node
        @callhook4(:onhandle, r, req, id)
        raw = callmethod(r, req, id)
        @callhook5(:onresponse, r, req, id, raw)
    else
        req[Symbol(r.name * "id")] = id
        route(r.subresources, req, popfirst!(req[:path]))
    end
    @callhook5(:onreturn, r, req, id, res)
end

function route(candidates::Vector{Resource}, req, id)
    ismatch(p::AbstractString) = p == "*" || p == id
    ismatch(p::Function) = p(id)
    ismatch(p::Regex) = Base.ismatch(p, id)

    i = findfirst(x->ismatch(x.route), candidates)
    if i == 0
        Response(404)
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

splitpath(p::AbstractString) = split(p, '/', keepempty=false)

function callmethod(r::Resource, req::Dict{Symbol, Any}, id::AbstractString)
    let m = r.methods, v = req[:method],
        h = [r.hooks[v]; (cb, r, req, id) -> haskey(m, v) ? m[v](req, id) : Response(405)]
        callone(i) = (req::Dict{Symbol, Any}, id::AbstractString) ->
            h[i](callone(i+1), r, req, id)
        callone(1)(req, id)
    end
end
