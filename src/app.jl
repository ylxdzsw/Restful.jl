function app()
    routing_rules = []

    function _add_handler(method)
        function handle(f::Function, path, fs...)
            push!(routing_rules, (method, path, fs..., f))
        end
        function handle(path, fs...)
            push!(routing_rules, (method, path, fs...))
        end
        handle
    end

    function _listen(address=ip"127.0.0.1", port=3001)
        routing_tree = build_routing_tree(routing_rules)

        HTTP.listen(address, port) do http::HTTP.Stream
            dump(http)
            req, res = context(http)
            route!(routing_tree, req, res)
            HTTP.setstatus(http, res.status)
            for (k, v) in res.headers
                HTTP.setheader(http, k => v)
            end
            HTTP.startwrite(http)
            write(http, res.body)
        end

        @info "listening at $address:$port"
    end

    (
        route = _add_handler("HOOK"),
        [method => _add_handler(uppercase(string(method))) for method in methods]...,
        listen = _listen
    )
end
