module Restful
    using HTTP
    using JSON2

    export app, json

    const methods = [:get, :post, :put, :patch, :delete, :head, :options]

    include("ctx.jl")
    include("route.jl")
    include("app.jl")
end
