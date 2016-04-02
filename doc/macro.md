### Macros

Rest.jl provides `@resource` macro as a grammar suger.

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
            Response(404, JSON.json(Dict(:error=>"Not Found")))
        end
    end

    "add a todoitem with specific id"
    :PUT => begin
        content = JSON.parse(req[:body]|>ASCIIString)["content"]
        _TODOLIST[id] = content
        Response(200)
    end

    :DELETE => begin
        if haskey(_TODOLIST, id)
            delete!(_TODOLIST, id)
            Response(200)
        else
            Response(404, JSON.json(Dict(:error=>"Not Found")))
        end
    end
end
```

- `todoitem <: todolist` defines `todoitem` as a subresource of `todolist`. `<: ::Resource` part is optional.
- `:name` and `:route` will be translate to `todoitem.name = ` directly. Both are optional.
- the strings are descriptions of the following RestMethods.
- `:VERB` defines the function that handles corresponding HTTP Verbs. Tow parameter `req` and `id` are generated.
