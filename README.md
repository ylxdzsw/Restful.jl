Restful.jl
=============================================

[![Build Status](https://travis-ci.org/ylxdzsw/Restful.jl.svg?branch=master)](https://travis-ci.org/ylxdzsw/Restful.jl)
[![Documentation Status](https://readthedocs.org/projects/restfuljl/badge/?version=latest)](http://restfuljl.readthedocs.org/en/latest/?badge=latest)
[![Coverage Status](https://coveralls.io/repos/github/ylxdzsw/Restful.jl/badge.svg?branch=master)](https://coveralls.io/github/ylxdzsw/Restful.jl?branch=master)
![Made with ❤](https://img.shields.io/badge/made%20with-%e2%9d%a4-ff69b4.svg?style=round-square)

An easy way to build simple but extendable RESTful servers.

### Installation

```julia
Pkg.add("Restful")
```

### Example

```julia
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
```

_notice that a Resource is a function that turns a Request into a Response, so it is a valid [Mux.jl](https://github.com/JuliaWeb/Mux.jl) endpoint._
