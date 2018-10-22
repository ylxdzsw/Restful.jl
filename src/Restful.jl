module Restful
    using HTTP
    export app, json

    const methods = [:get, :post, :put, :patch, :delete, :head, :options]

    include("app.jl")
    include("route.jl")

    include("Default.jl")
    using .Default

    include("Json.jl")
    using .Json
end
