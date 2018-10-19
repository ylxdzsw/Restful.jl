struct RouteNode
    name::Union{String, Nothing}
    handler::Dict{String, Function}
    hook::Vector{Function}
    children::Vector{RouteNode}
end

RouteNode(name=nothing) = RouteNode(name, Dict{String, Function}(), Funciton[], RouteNode[])

function find_node(seg)::RouteNode
    magic()
end

function (node::RouteNode)(path, req, res)

end

function build_routing_tree(rules)
    root = RouteNode("")

    for rule in rules
        method, url, handler = rule
        node = find_node(split(url, '/'))

        if method == "HOOK"
            push!(node.hook, handler)
        else
            method in node.handler && @warn "replace handler for $method:$url"
            node.handler[method] = handler
        end

        push!(node.hook, rule[4:end]...)
    end

    root
end
