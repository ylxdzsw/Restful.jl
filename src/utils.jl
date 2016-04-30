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
    req[:body] = JSON.parse(req[:body] |> UTF8String)
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

@mixin defaultmixin begin
    :onresponse => [makeresponse, response_option, add_allow_header]
end
