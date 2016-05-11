import JSON

export defaultmixin

makeresponse(r::Resource, req, id, res) = Response(res)

add_allow_header(r::Resource, req, id, res::Response) = if !haskey(res.headers, "Allow")
    res.headers["Allow"] = join(keys(r.methods), ", ")
end

response_option(r::Resource, req, id, res) = if res.status == 405 && req[:method] == :OPTIONS
    Response(200, help(r))
end

json(next, r::Resource, req, id) = begin
    try
        req[:body] = JSON.parse(req[:body] |> UTF8String)
    end
    res = next(req, id)
    isa(res, Union{Dict, Vector}) || return res
    res = res |> JSON.json |> Response
    res.headers["Content-Type"] = "application/json"
    res
end

cors(r::Resource, req, id, res) = begin
    ACAO = "Access-Control-Allow-Origin"
    ACRH = "Access-Control-Request-Headers"
    ACAH = "Access-Control-Allow-Headers"
    ACRM = "Access-Control-Request-Method"
    ACAM = "Access-Control-Allow-Methods"
    res.headers[ACAO] = "*"
    if haskey(req[:headers], ACRH)
        res.headers[ACAH] = req[:headers][ACRH]
    end
    if haskey(req[:headers], ACRM)
        res.headers[ACAM] = req[:headers][ACRM]
    end
end

cors(next::Function, r::Resource, req, id) = begin
    res = next(req, id)
    cors(r, req, id, res)
    res
end

@mixin defaultmixin begin
    :onresponse => [makeresponse, response_option, add_allow_header]
end

staticserver(dir::AbstractString="."; cache::Int=0) =
    (r::Resource, req, id) -> begin
        filepath = joinpath(dir, req[:path]...)
        ext = splitext(filepath)[2][2:end]

        isfile(filepath) || return Response(404)

        mt = mtime(filepath) |> Dates.unix2datetime
        mt -= Dates.Millisecond(Dates.millisecond(mt))

        if "If-Modified-Since" in keys(req[:headers])
            try # ignore any error
                if mt <= DateTime(req[:headers]["If-Modified-Since"], Dates.RFC1123Format)
                    return Response(304)
                end
            end
        end

        res = open(readbytes, filepath) |> Response
        res.headers["Content-Type"] = get(HttpServer.mimetypes, ext, "application/octet-stream") # text/plain should be better?
        res.headers["Last-Modified"] = Dates.format(mt, Dates.RFC1123Format)
        res
    end

module JLT
    cache = Dict{AbstractString, Function}()

    """
    template string -> function
    """
    function compile(x::AbstractString)
        raw = split(x, "\$\$")
        buf = IOBuffer(length(x.data) + length(raw)*32 + 128)

        iscode = false # indicating if i is code

        write(buf, "(JLT_output::IO, data::Dict{Symbol, Any}) -> begin\n")

        for i in raw
            if iscode
                write(buf, '\n', i, '\n')
            else
                write(buf, "write(JLT_output, \"\"\"", i, "\"\"\")")
            end

            iscode = !iscode
        end

        write(buf, "\nJLT_output\nend")

        buf |> seekstart |> readall |> parse |> eval # eval in the JLT module
    end

    "filepath -> rendered string"
    function render(file::AbstractString; kwargs...)
        f = open(readall, file) |> compile
        buf = IOBuffer()
        f(buf, Dict{Symbol, Any}(kwargs)) |> seekstart |> readall
    end

    """
    like render but cache the compiled function.
    can be about 1000x faster in some cases.
    """
    function render_with_cache(file::AbstractString; kwargs...)
        if haskey(cache, file)
            buf = IOBuffer()
            cache[file](buf, Dict{Symbol, Any}(kwargs)) |> seekstart |> readall
        else
            cache[file] = open(readall, file) |> compile
            render_with_cache(file; kwargs...)
        end
    end
end
