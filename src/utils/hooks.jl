import JSON

json(next, r::Resource, req, id) = begin
    try
        req[:body] = JSON.parse(req[:body] |> String)
    catch
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
