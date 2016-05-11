export defaultmixin

makeresponse(r::Resource, req, id, res) = Response(res)

add_allow_header(r::Resource, req, id, res::Response) = if !haskey(res.headers, "Allow")
    res.headers["Allow"] = join(keys(r.methods), ", ")
end

response_option(r::Resource, req, id, res) = if res.status == 405 && req[:method] == :OPTIONS
    Response(200, help(r))
end

@mixin defaultmixin begin
    :onresponse => [makeresponse, response_option, add_allow_header]
end
