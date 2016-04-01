using Rest
using HttpServer
using Base.Test

import JSON
import Requests: get, post, put, delete, options, readall, statuscode

_TODOLIST = Dict()

todolist = Resource("todolist")
todoitem = Resource("todoitem", route="*")

addsubresource(todolist, todoitem)

addmethod(todolist, :GET) do req, _
    Response(200, JSON.json(collect(keys(_TODOLIST))))
end

addmethod(todolist, :POST) do req, _
    content       = JSON.parse(req[:body]|>ASCIIString)["content"]
    id            = string(hash(content))
    _TODOLIST[id] = content
    Response(200, JSON.json(Dict(:id=>id)))
end

addmethod(todoitem, :GET) do req, id
    if haskey(_TODOLIST, id)
        Response(200, JSON.json(Dict(:content=>_TODOLIST[id])))
    else
        Response(404, JSON.json(Dict(:error=>"Not Found")))
    end
end

addmethod(todoitem, :PUT) do req, id
    content = JSON.parse(req[:body]|>ASCIIString)["content"]
    _TODOLIST[id] = content
    Response(200)
end

addmethod(todoitem, :DELETE) do req, id
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

url(x) = "http://127.0.0.1:8000$x"

@test readall(get(url("/"))) == "[]"
@test statuscode(put(url("/10086"), json=Dict(:content=>"eat apple"))) == 200
@test JSON.parse(readall(get(url("/10086"))))["content"] == "eat apple"
@test readall(get(url("/"))) == "[\"10086\"]"
@test statuscode(delete(url("/10086"))) == 200
@test JSON.parse(readall(get(url("/10086"))))["error"] == "Not Found"
@test readall(get(url("/"))) == "[]"
@test JSON.parse(readall(post(url("/"), json=Dict(:content=>"drink water"))))["id"] ==
      JSON.parse(readall(get(url("/"))))[1]
