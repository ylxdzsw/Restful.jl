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
            catch
            end
        end

        res = open(read, filepath) |> Response
        res.headers["Content-Type"] = get(HttpServer.mimetypes, ext, "application/octet-stream") # text/plain should be better?
        res.headers["Last-Modified"] = Dates.format(mt, Dates.RFC1123Format)
        res
    end
