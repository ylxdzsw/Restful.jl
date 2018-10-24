module Default
    using HTTP
    export default

    function default(req, res, route)
        res[:text] = this -> x -> let
            this.status = 200
            this.body = string(x)
            this.content_type = "text/plain"
        end

        res[:code] = this -> x -> let
            this.status = x
            # TODO: check x and add information?
        end

        res[:html] = this -> x -> let
            this.status = 200
            this.body = x
            this.content_type = "text/html"
        end

        req[:params] = this -> this.params = HTTP.URIs.queryparams(this.uri)

        req.body = read(req._http, String)
        route.next()

        if res.route_status != nothing
            @error "not found" req.method req.uri.uri
            res.code(res.route_status)
        end

        if res.body != nothing
            res.content_type != nothing && push!(res.headers, "Content-Type" => res.content_type)
            res.body isa IO || push!(res.headers, "Content-Length" => string(sizeof(res.body)))
        end
    end
end
