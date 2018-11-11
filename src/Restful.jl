module Restful
    using HTTP

    const methods = [:get, :post, :put, :patch, :delete, :head, :options]

    include("app.jl")
    include("route.jl")

    include("Default.jl")
    using .Default

    include("Json.jl")
    using .Json

    include("Template.jl")
    using .Template
end
