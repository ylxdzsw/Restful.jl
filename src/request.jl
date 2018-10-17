module LazyDicts
    import Base: getproperty, setproperty!, setindex!
    export LazyDict

    struct LazyEntry
        f::Function
    end

    struct LazyDict{T} # <: AbstractDict{Symbol, T}
        dict::Dict{Symbol, Union{T, LazyEntry}}
        LazyDict{T}(x...) where T = new{T}(Dict{Symbol, Union{T, LazyEntry}}(x...))
    end
    LazyDict(x...) = LazyDict{Any}(x...)

    function getproperty(d::LazyDict, field::Symbol)
        v = getfield(d, :dict)[field]
        if v isa LazyEntry
            getfield(d, :dict)[field] = v.f()
        else
            v
        end
    end

    function setproperty!(d::LazyDict, field::Symbol, value)
        getfield(d, :dict)[field] = value
    end

    function setindex!(f::Function, d::LazyDict, field::Symbol)
        getfield(d, :dict)[field] = LazyEntry(value)
    end
end

using .LazyDicts

