module Restful
    using HTTP

    export Utils

    include("constants.jl")
    include("RestMethod.jl")
    include("Resource.jl")
    include("Mixin.jl")
    include("route.jl")
    include("macros.jl")

    module Utils
        using ..Restful

        include("utils/hooks.jl")
        include("utils/mixins.jl")
        include("utils/staticserver.jl")
        include("utils/template.jl")
    end
end
