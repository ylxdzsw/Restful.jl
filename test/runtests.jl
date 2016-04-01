using Rest
using HttpServer
using Base.Test

todolist = Resource("todolist")

addmethod(todolist, :GET) do req
    Response(200, "hello world")
end

app = HttpHandler() do req::Request, res::Response
    todolist(req)
end

@async run(Server(app), host=ip"127.0.0.1", port=8000)

"All test cases pass (0/0)" |> println
