using Restful
using Test

import Restful: json

const db = Dict()

const app = Restful.app()

app.route("/") do req, res, route
    res.text("Hello World?")
end

app.get("/todo", json) do req, res, route
    res.json(keys(db) |> collect)
end

app.post("/todo", json) do req, res, route
    id = req.body |> hash |> string
    db[id] = req.body
    res.json(;id=id)
end

app.get("/todo/:id", json) do req, res, route
    route.id in keys(db) ? res.json(;content=db[route.id]) : res.code(404)
end

app.put("/todo/:id", json) do req, res, route
    db[route.id] = req.body["content"]
    res.code(200)
end

app.delete("/todo/:id", json) do req, res, route
    if route.id in keys(db)
        delete!(db, route.id)
        res.code(200)
    else
        res.code(404)
    end
end

@async app.listen(ip"127.0.0.1", 3001)

isinteractive() || wait()


"""
url(x) = "http://127.0.0.1:3001$x"

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
"""
