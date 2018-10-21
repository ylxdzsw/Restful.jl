module PDicts
    import Base: getproperty, setproperty!, setindex!
    export PDict

    struct PDict
        dict::Dict{Symbol, Any}
        proto::Dict{Symbol, Function}
        PDict(x...) = (Dict{Symbol, Any}(x...), Dict{Symbol, Function}())
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

    function setindex!(f::Function, d::PDict, field::Symbol)
        getfield(d, :proto)[field] = f
    end
end

module Headers
    import Base: getindex
    export Header

    struct Header
        headers::Vector{Pair{String, String}}
    end

    getindex(h::Header, key) = HTTP.header(h.headers, key)
end

using .PDicts
using .Headers

function context(http::HTTP.Stream)
    uri = HTTP.URIs.parse_uri(http.message.target)
    header = Header(http.message.headers)
    PDict(:_http=>http, :method=>http.message.method, :uri=>uri, :header=>header), PDict()
end
