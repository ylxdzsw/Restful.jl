export RestMethod

mutable struct RestMethod
    description::AbstractString
    f::Function
end

RestMethod(f::Function, d::AbstractString) = RestMethod(d, f)

(r::RestMethod)(args...; kargs...) = r.f(args...; kargs...)
