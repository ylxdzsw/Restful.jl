using Restful
using Test
using HTTP
using JSON2
using Logging

import Restful: json

const db = Dict()
const app = Restful.app()

app.get("/") do req, res, route
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
    db[route.id] = req.json.content
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

@async with_logger(SimpleLogger(stderr, Logging.Warn)) do
    app.listen("127.0.0.1", 3001)
end

macro u_str(x)
    "http://127.0.0.1:3001$x"
end

@test String(HTTP.get(u"/").body) == "Hello World?"
@test HTTP.put(u"/todo/39", [], JSON2.write((content="task a",))).status == 200
@test String(HTTP.get(u"/todo/39").body) == "{\"content\":\"task a\"}"
@test String(HTTP.get(u"/todo").body) == "[\"39\"]"
@test HTTP.delete(u"/todo/39").status == 200
@test HTTP.get(u"/todo/39", status_exception=false).status == 404
@test String(HTTP.get(u"/todo").body) == "[]"
@test JSON2.read(String(HTTP.post(u"/todo", [], JSON2.write((content="task b",))).body)).id ==
      JSON2.read(String(HTTP.get(u"/todo").body))[1]
@test HTTP.put(u"/", status_exception=false).status == 405
# @test headers(put(url("/todo")))["Allow"] == "GET, POST"

app.close()
