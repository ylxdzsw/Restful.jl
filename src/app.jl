import Base: getproperty, setproperty!, setindex!
import Sockets

struct PDict
    dict::Dict{Symbol, Any}
    proto::Dict{Symbol, Function}
    PDict(x...) = new(Dict{Symbol, Any}(x...), Dict{Symbol, Function}())
end

function getproperty(d::PDict, field::Symbol)
    dict = getfield(d, :dict)
    field in keys(dict) && return dict[field]

    proto = getfield(d, :proto)
    field in keys(proto) && return proto[field](d)

    # throw(KeyError(field))
    nothing
end

function setproperty!(d::PDict, field::Symbol, value)
    getfield(d, :dict)[field] = value
end

function setindex!(d::PDict, f::Function, field::Symbol)
    getfield(d, :proto)[field] = f
end

function context(http::HTTP.Stream)
    req = PDict(:_http=>http, :method=>http.message.method, :uri=>HTTP.URIs.URI(http.message.target))
    req[:header] = this -> this.header = Dict(this._http.message.headers)

    res = PDict(:headers=>Pair{String, String}[], :status=>500)

    req, res
end

function app()
    routing_rules, server = [], nothing

    function _add_handler(method)
        function handle(f::Function, path, fs...)
            push!(routing_rules, (method, path, fs..., f))
        end
        function handle(path, fs...)
            push!(routing_rules, (method, path, fs...))
        end
        handle
    end

    function _listen(address="127.0.0.1", port=3001)
        routing_tree = build_routing_tree(routing_rules)
        server = Sockets.listen(parse(Sockets.IPAddr, address), port)

        HTTP.listen(address, port, server=server) do http::HTTP.Stream
            req, res = context(http)
            routing_tree(req, res)
            HTTP.setstatus(http, res.status)
            for (k, v) in res.headers
                HTTP.setheader(http, k => v)
            end
            HTTP.startwrite(http)
            res.body != nothing && write(http, res.body)
        end
    end

    (
        route = _add_handler("HOOK"),
        [method => _add_handler(uppercase(string(method))) for method in methods]...,
        listen = _listen,
        close = () -> server != nothing && close(server)
    )
end
