module Restful

using HttpServer
using URIParser

include("constants.jl")
include("RestMethod.jl")
include("Resource.jl")
include("Mixin.jl")
include("route.jl")
include("macros.jl")

include("utils/hooks.jl")
include("utils/JLT.jl")
include("utils/mixins.jl")
include("utils/staticserver.jl")

end # module Restful
