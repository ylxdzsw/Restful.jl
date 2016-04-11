using Restful
using HttpServer
using Base.Test

import JSON
import Requests: get, post, put, delete, options,
                 readall, statuscode, headers

_TODOLIST = Dict()

json(next, r::Resource, req, id) = begin
    req[:body] = JSON.parse(req[:body] |> ASCIIString)
    res = next(req, id)
    isa(res, Dict) ? JSON.json(res) : res
end

todolist = Resource("todolist")

addmethod!(todolist, :GET) do req, _
    Response(200, JSON.json(collect(keys(_TODOLIST))))
end

addmethod!(todolist, :POST) do req, _
    content       = JSON.parse(req[:body]|>ASCIIString)["content"]
    id            = string(hash(content))
    _TODOLIST[id] = content
    Response(200, JSON.json(Dict(:id=>id)))
end

addmixin!(todolist, defaultmixin)

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

@async run(Server(todolist), host=ip"127.0.0.1", port=8000)

url(x) = "http://127.0.0.1:8000$x"

@test readall(get(url("/"))) == "[]"
@test statuscode(put(url("/10086"), json=Dict(:content=>"eat apple"))) == 200
@test JSON.parse(readall(get(url("/10086"))))["content"] == "eat apple"
@test readall(get(url("/"))) == "[\"10086\"]"
@test statuscode(delete(url("/10086"))) == 200
@test statuscode(get(url("/10086"))) == 404
@test readall(get(url("/"))) == "[]"
@test JSON.parse(readall(post(url("/"), json=Dict(:content=>"drink water"))))["id"] ==
      JSON.parse(readall(get(url("/"))))[1]
@test statuscode(put(url("/"))) == 405
# @test headers(put(url("/")))["Allow"] == "GET, POST"
