module Template
    export template

    const cache = Dict{AbstractString, Function}()

    """
    low-level API; template string + argnames -> (args -> rendered string)
    """
    function compile(x::AbstractString, argnames::Symbol...) # TODO: escape """, auto find free variables
        raw = split(x, "\$\$")
        buf = IOBuffer(sizehint = sizeof(x) + length(raw)*32 + 128)

        arglist = join(("$x=throw(ArgumentError(\"missing required argument $x\"))" for x in argnames), ',')

        write(buf, "(_o42CzdTO::IO; ", arglist, ") -> begin\n")

        iscode = false # indicating if i is code
        for i in raw
            if iscode
                write(buf, '\n', i, '\n')
            else
                write(buf, "write(_o42CzdTO, \"\"\"", i, "\"\"\")")
            end

            iscode = !iscode
        end

        write(buf, "\n_o42CzdTO\nend")

        buf |> take! |> String |> Meta.parse |> eval
    end

    """
    render with cache; automatically determin argnames by the arguments of first call
    filepath and args -> rendered string
    """
    function render(file::AbstractString; kwargs...)
        f = Base.@get!(cache, file, compile(read(file, String), keys(kwargs)...))
        Base.invokelatest(f, IOBuffer(); kwargs...)::IOBuffer |> take! |> String
    end

    function template(req, res, route)
        res[:render] = this -> (file; kwargs...) -> begin
            this.status = 200
            this.body = render(file; kwargs...)
            this.content_type = "text/html"
        end

        route.next()
    end
end
