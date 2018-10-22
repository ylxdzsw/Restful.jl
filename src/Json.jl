module Json
    import JSON2
    export json

    function json(req, res, route)
        req[:json] = this -> this.json = try
            JSON2.read(this.body)
        catch e
            @error "invalid json" this.body
            return res.code(400)
        end

        res[:json] = this -> let
            function _json(x)
                this.status = 200
                this.body = JSON2.write(x)
                this.content_type = "application/json"
            end
            _json(;x...) = _json(x.data)
        end

        route.next()
    end
end
