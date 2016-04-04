### Route

In Restful.jl, resources are structured as a tree. A Request starts from the
root and be passed through subresources until reaching the end.

Valid route rules are either a ASCIIString or a Function that accepts a string and
returns a Bool. "*" will match any strings.

For example, there is a few teams, each team has a leader, some members
(member ids are 4 letter long) and some projects(project ids are 6 letter long).
A tree structure can be like this:

```julia
@resource teams begin end
@resource team <: teams begin
    :route => "*"
end
@resource leader <: team begin
    :route => "leader"
end
@resource member <: team begin
    :route => (id) -> length(id) == 4
end
@resource project <: team begin
    :route => (id) -> length(id) == 6
end
```

When a request of "/teams/front-end/0001" comes, it will be passed to `team` as
"*" can match any strings(for this example, "front-end"). Then Rest.jl will try
to match "0001" with the route rules of `leader`, `member` and `project`, and finally
reach `member`. As no more path segments exists, Rest.jl will invoke the coresponding
HTTP verb method of `member`.
