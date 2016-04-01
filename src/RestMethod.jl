export RestMethod

import Base.call

type RestMethod
    description::AbstractString
    f::Function
end

RestMethod(f::Function, d::AbstractString) = RestMethod(d, f)

Base.call(r::RestMethod, args...; kargs...) = r.f(args...; kargs...)
