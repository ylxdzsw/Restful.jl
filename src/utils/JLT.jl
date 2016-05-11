module JLT

export compile, render, render_with_cache

cache = Dict{AbstractString, Function}()

"""
template string -> function
"""
function compile(x::AbstractString)
    raw = split(x, "\$\$")
    buf = IOBuffer(length(x.data) + length(raw)*32 + 128)

    iscode = false # indicating if i is code

    write(buf, "(JLT_output::IO, data::Dict{Symbol, Any}) -> begin\n")

    for i in raw
        if iscode
            write(buf, '\n', i, '\n')
        else
            write(buf, "write(JLT_output, \"\"\"", i, "\"\"\")")
        end

        iscode = !iscode
    end

    write(buf, "\nJLT_output\nend")

    buf |> seekstart |> readall |> parse |> eval # eval in the JLT module
end

"""
filepath -> rendered string
"""
function render(file::AbstractString; kwargs...)
    f = open(readall, file) |> compile
    buf = IOBuffer()
    f(buf, Dict{Symbol, Any}(kwargs)) |> seekstart |> readall
end

"""
like render but cache the compiled function.
can be about 1000x faster in some cases.
"""
function render_with_cache(file::AbstractString; kwargs...)
    if haskey(cache, file)
        buf = IOBuffer()
        cache[file](buf, Dict{Symbol, Any}(kwargs)) |> seekstart |> readall
    else
        cache[file] = open(readall, file) |> compile
        render_with_cache(file; kwargs...)
    end
end

end # module JLT
