using Rest
using Base.Test

todolist = Resource("todolist", "todo list")
todoitem = Resource("todoitem", "todo item")

@addmethod todolist, :GET, "get the list of todoitems", req -> begin
    "hello world"
end

run(todolist, IP"127.0.0.1", 8000)

"All test cases pass (0/0)" |> println
