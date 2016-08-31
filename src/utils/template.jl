const cache = Dict{AbstractString, Function}()

"""
low-level API; template string + argnames -> (args -> rendered string)
"""
function compile(x::AbstractString, argnames::Symbol...) # TODO: escape `"""`
    raw = split(x, "\$\$")
    buf = IOBuffer(length(x.data) + length(raw)*32 + 128)

    iscode = false # indicating if i is code

    arglist = join(("$x=throw(error(\"missing required argument $x\"))" for x in argnames), ',')

    write(buf, "(_out::IO; ", arglist, ") -> begin\n")

    for i in raw
        if iscode
            write(buf, '\n', i, '\n')
        else
            write(buf, "write(_out, \"\"\"", i, "\"\"\")")
        end

        iscode = !iscode
    end

    write(buf, "\n_out\nend")

    buf |> takebuf_string |> parse |> eval # eval in the Restful module
end

"""
render with cache; automatically determin argnames by the arguments of first call
filepath and args -> rendered string
"""
function render(file::AbstractString; kwargs...) # maybe we can use @generated to perform cache
    if haskey(cache, file)
        buf = IOBuffer()
        cache[file](buf; kwargs...) |> takebuf_string
    else
        cache[file] = compile(open(readstring, file), map(x->x[1], kwargs)...)
        render(file; kwargs...)
    end
end
