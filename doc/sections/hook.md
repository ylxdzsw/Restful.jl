### hooks

Hooks are functions that triggers at specific times, acting like middlewares in many other frameworks.

Currently there are three types of hooks:

#### preroute

`(r::Resource, req::Dict{Symbol, Any}, id::AbstractString) -> Any`

Triggered before a request handled by this resource or passed to a child resource.

It returns a `Dict{Symbol, Any}` to replace `req` for the following handlers, or returns a `Response` to end this request and respond. When it returns other things, the returned value will be ignored. However, modifications to `req` works.

#### onresponse

`(r::Resource, req::Dict{Symbol, Any}, id::AbstractString) -> Response(Any)`

Triggered after a request handled by this resource. You can return `Any` but be sure that it will be replaced to a real `Response` by other hooks.
