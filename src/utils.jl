addAllowHeader(r::Resource, req, id, res::Response) = if !haskey(res.headers, "Allow")
    res.headers["Allow"] = join(keys(r.methods), ", ")
end
makeresponse(r::Resource, req, id, res) = Response(res)
