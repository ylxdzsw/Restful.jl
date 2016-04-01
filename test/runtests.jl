using Rest
using HttpServer
using Requests
using Base.Test

import JSON

_TODOLIST = Dict{UInt64, UTF8String}()

todolist = Resource("todolist")
todoitem = Resource("todoitem", route="*")

addsubresource(todolist, todoitem)

addmethod(todolist, :GET) do req, _
    Response(200, JSON.json(collect(keys(_TODOLIST))))
end

addmethod(todolist, :POST) do req, _
    content       = JSON.parse(req[:body]|>ASCIIString)["content"]
    id            = hash(content)
    _TODOLIST[id] = content
    Response(200, JSON.json(Dict(:id=>id)))
end

addmethod(todoitem, :GET) do req, id
    id = parse(UInt64, id)
    if haskey(_TODOLIST, id)
        Response(200, JSON.json(Dict(:content=>_TODOLIST[id])))
    else
        Response(404, JSON.json(Dict(:error=>"Not Found")))
    end
end

addmethod(todoitem, :PUT) do req, id
    id = parse(UInt64, id)
    content = JSON.parse(req[:body]|>ASCIIString)["content"]
    _TODOLIST[id] = content
    Response(200)
end

addmethod(todoitem, :DELETE) do req, id
    id = parse(UInt64, id)
    if haskey(_TODOLIST, id)
        delete!(_TODOLIST, id)
        Response(200)
    else
        Response(404, JSON.json(Dict(:error=>"Not Found")))
    end
end

app = HttpHandler() do req::Request, res::Response
    todolist(req)
end

@async run(Server(app), host=ip"127.0.0.1", port=8000)

"All test cases pass (0/0)" |> println
