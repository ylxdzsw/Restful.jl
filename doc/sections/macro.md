### Macros

Restful.jl provides `@resource` macro as a grammar suger.

Here is an example:

```julia
@resource todoitem <: todolist begin
    :name  => "todoitem"
    :route => "*"

    "get a todoitem content"
    :GET => begin
        if haskey(_TODOLIST, id)
            Response(200, JSON.json(Dict(:content=>_TODOLIST[id])))
        else
            404
        end
    end

    "add a todoitem with specific id"
    :PUT => begin
        _TODOLIST[id] = JSON.parse(req[:body]|>ASCIIString)["content"]
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
