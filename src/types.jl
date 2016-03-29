type Resource
    name::AbstractString
    descriptions::Dict{Symbol, AbstractString}
    methods::Dict{Symbol, Function}
    subresource::Resource

    Resource(name::AbstractString = "",
             descriptions::Dict{Symbol, AbstractString} = Dict{Symbol, AbstractString}(),
             methods::Dict{Symbol, Function} = Dict{Symbol, Function}()) =
        new(name, descriptions, methods)
end


