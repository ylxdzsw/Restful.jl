# TODO: make it type-stable?
# type parameters can be (nested) Symbol, Tuple, Function, and NametedTuple
# so we can embed all hooks and req prototypes into the type parameter
struct RouteNode
    name::String
    hook::Dict{String, Vector{Function}}
    children::Vector{RouteNode}
end

RouteNode(name) = RouteNode(name, Dict(x => Function[] for x in [map(uppercase∘string, methods); "HOOK"]), RouteNode[])

function find_node(node, seg, i=1)::RouteNode
    i > length(seg) && return node
    token = seg[i]
    child = findfirst(x->startswith(x.name, ':') || x.name == token, node.children)
    if child == nothing
        push!(node.children, RouteNode(token))
        child = length(node.children)
    end
    find_node(node.children[child], seg, i+1)
end

function (node::RouteNode)(req, res)
    seg, route = HTTP.URIs.splitpath(req.uri.path), PDict(:node=>node)

    function _continue_route(node, k)
        if k > length(seg)
            method = req.method
            isempty(node.hook[method]) && return res.route_status = 405
            return _continue_handle(node.hook[method], 1)
        end

        token = seg[k]
        child = findfirst(x->startswith(x.name, ':') || x.name == token, node.children)
        if child == nothing
            return res.route_status = 404
        end
        node = node.children[child]
        route.node = node
        startswith(node.name, ':') && setproperty!(route, Symbol(SubString(node.name, 2)), token)
        return _continue_hook(node, node.hook["HOOK"], 1, k+1)
    end

    function _continue_hook(node, hooks, i, k)
        i > length(hooks) && return _continue_route(node, k)
        route.next = () -> _continue_hook(node, hooks, i+1, k)
        hooks[i](req, res, route)
    end

    function _continue_handle(handlers, i)
        i > length(handlers) && return @warn "the last handler calls `next`" path='/'*join(seg, '/')
        route.next = () -> _continue_handle(handlers, i+1)
        handlers[i](req, res, route)
    end

    _continue_hook(node, node.hook["HOOK"], 1, 1)
end

function build_routing_tree(rules)
    root = RouteNode("")
    push!(root.hook["HOOK"], default) # attach the default hook, which is a part of the basic Restful functionality

    for rule in rules
        method, path = rule
        node = find_node(root, HTTP.URIs.splitpath(path))
        push!(node.hook[method], rule[3:end]...)
    end

    root
end
