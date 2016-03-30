using Rest
using Base.Test

todolist = Resource("todolist")

addmethod(todolist, :GET) do req
    "hello world"
end

run(todolist, IP"127.0.0.1", 8000)

"All test cases pass (0/0)" |> println
