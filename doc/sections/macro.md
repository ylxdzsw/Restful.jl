### Macros

Restful.jl provides `@resource` macro as a grammar suger.

Here is an example:

```julia
@resource todoitem <: todolist begin
    :name  => "todoitem"
    :route => "*"
    :mixin => [defaultmixin]

    "get a todoitem content"
    :GET | json => begin
        if haskey(_TODOLIST, id)
            Dict(:content=>_TODOLIST[id])
        else
            404
        end
    end

    "add a todoitem with specific id"
    :PUT | json => begin
        _TODOLIST[id] = req[:body]["content"]
        200
    end

    :DELETE => begin
        if haskey(_TODOLIST, id)
            delete!(_TODOLIST, id)
            200
        else
            404
        end
    end
end
```

- `todoitem <: todolist` defines `todoitem` as a subresource of `todolist`. `<: ::Resource` part is optional.
- `:name` and `:route` will be translate to `todoitem.name = ` directly. Both are optional.
- the strings are descriptions of the following RestMethods.
- `:VERB` defines the function that handles corresponding HTTP Verbs. Tow parameter `req` and `id` are generated.
- `|` defines method hooks, see [hooks](hooks.html).

The `@mixin` is like `@resource`, but it can only define hooks.

```julia
timestart(r, req, id) = req["request time"] = now()
timeend(r, req, id, res) = now() - req["request time"] |> println

@mixin timer begin
    :preroute => [timestart]
    :onreturn => [timeend]
end
```
