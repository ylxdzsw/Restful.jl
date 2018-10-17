function app()
    routing_rules = []

    _add_handler(method) = (handler, url, middlewares...) -> begin
        push!(routing_rules, (method, url, handler, middlewares...))
    end

    function _add_hook(hook, url, middlewares...)
        push!(routing_rules, (:HOOK, url, hook, middlewares...))
    end

    function listen(address=ip"127.0.0.1", port=3001)
        routing_tree = build_routing_tree(routing_rules)

        HTTP.listen(address, port) do http

        end

        @info "listening at $address:$port"
    end

    (
        route = _add_hook,

        get = _add_handler(:GET),
        post = _add_handler(:POST),
        put = _add_handler(:PUT),
        patch = _add_handler(:PATCH),
        delete = _add_handler(:DELETE),
        head = _add_handler(:HEAD),
        options = _add_handler(:OPTIONS),

        listen = listen
    )
end
