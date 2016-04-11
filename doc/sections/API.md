### Types

#### Resource

Resource has four properties:
- name: be used to indicate this resource. default: ""
- route: route rule of this resource, see [route](route.html). default: name
- methods: RestMethod that handles specific HTTP verb. default: RestMethod[]
- subresources: resources that belongs to this one. deault: Resource[]
- hooks: see [`hook`](hook.html)

There are three ways to define a Resource:
0. use the constructor. It is useful when you have methods and subresources defined already.
0. make an empty Resource, then use [`addmethod`](#addmethod-r-resource-t-symbol-d-abstractstring-f-function) and [`addsubresource`](#addsubresource-r-resource-s-resource) to complete it.
0. *(recommended)* use the [`@resource`](macro.html) macro.

#### RestMethod

Simply a function with descriptions. You may not need to create it manually.

#### Mixin

a Mixin is a collection of hooks, created by [@mixin](macro.html). see [`hook`](hook.html)

### Functions

#### addmethod(r::Resource, t::Symbol, d::AbstractString, f::Function)

Add a RestMethod to a Resource. `do` syntax is also supported.

`f` should be like this: `(req::Dict{Symbol, Any}, id::AbstractString) -> Response`
where `id` is the segment that match the route rule of this resource, and `req` contains at least these things:

- `:method`: one of HTTP verbs like `:GET`.
- `:headers`: the header Dict generate by [HttpServer](https://github.com/JuliaWeb/HttpServer.jl).
- `:body`: the byte data of request.
- `:path`: `Vector{SubString{AbstractString}}` contains url segments splited by '/'. Empty segments are not keeped.
- `:query`: `Dict{ASCIIString,ASCIIString}` contains url queries.
- `:Xid`: the id of ancestor resource X.

#### addsubresource(r::Resource, s::Resource)

Make the first Resouce a subresource of the second one.

#### Base.call(r::Resource, req::Request)

Route through the resource tree and find the proper method to handle the request.
