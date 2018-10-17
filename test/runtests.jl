using Restful
using Test

import Restful: json

const db = Dict()

const app = Restful.app()

app.route("/") do req
    "Hello World?"
end

app.get("/todo", json) do req
    keys(db) |> collect
end

app.post("/todo", json) do req
    id = req.body |> hash |> string
    db[id] = req.body
    (id=id,)
end

app.get("/todo/:id", json) do req, id
    if id in keys(db)
        (content=db[id],)
    else
        404
    end
end

app.put("/todo/:id", json) do req, id
    db[id] = req.body["content"]
    200
end

app.delete("/todo/:id", json) do req, id
    if id in keys(db)
        delete!(db, id)
        200
    else
        404
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
