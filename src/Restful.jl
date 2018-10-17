module Restful
    using HTTP
    using JSON2

    export app, json

    const METHODS = [:GET, :POST, :PUT, :PATCH, :DELETE, :COPY, :HEAD, :OPTIONS]

    include("req.jl")
    include("route.jl")
    include("app.jl")
end
