exit(0)
using Restful
using HttpServer
using Test

import JSON
import Requests: get, post, put, delete, options, statuscode, headers
import Restful.json

_TODOLIST = Dict()

@resource todolist begin
    :mixin => [defaultmixin]

    :GET | json => begin
        _TODOLIST |> keys |> collect
    end

    :POST | json => begin
        id = req[:body] |> hash |> string
        _TODOLIST[id] = req[:body]
        Dict(:id=>id)
    end
end

@resource todoitem <: todolist begin
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

@test read(get(url("/")), String) == "[]"
@test statuscode(put(url("/10086"), json=Dict(:content=>"eat apple"))) == 200
@test JSON.parse(read(get(url("/10086")), String))["content"] == "eat apple"
@test read(get(url("/")), String) == "[\"10086\"]"
@test statuscode(delete(url("/10086"))) == 200
@test statuscode(get(url("/10086"))) == 404
@test read(get(url("/")), String) == "[]"
@test JSON.parse(read(post(url("/"), json=Dict(:content=>"drink water")), String))["id"] ==
      JSON.parse(read(get(url("/")), String))[1]
@test statuscode(put(url("/"))) == 405
@test headers(put(url("/")))["Allow"] == "GET, POST"
