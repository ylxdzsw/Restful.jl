export @resource

macro codegen(ex)
    :( push!(result.args, $(Expr(:quote, ex))) )
end

macro resource(declaration, content)
    result = Expr(:block)
    if isa(declaration, Expr)
        this   = declaration.args[1]
        super  = declaration.args[3]
        @codegen $this = Resource()
        @codegen addsubresource!($super, $this)
    elseif isa(declaration, Symbol)
        this = declaration
        @codegen $declaration = Resource()
    else
        error("unexpected $(declaration)")
    end

    local description = ""
    for i in content.args
        if isa(i, AbstractString)
            description = i
        elseif i.head == :line
            continue
        elseif i.head == :(=>)
            key = i.args[1].args[1]
            if key == :name
                @codegen $(this).name = $(i.args[2])
            elseif key == :route
                @codegen $(this).route = $(i.args[2])
            elseif key in setdiff(HOOKS, METHODS)
                @codegen hook!($this, $(Expr(:quote, key)), $(i.args[2]))
            else
                (hooks, method) = parsepipe(i.args[1])
                @codegen hook!($this, $method, $(Expr(:ref, :Function, hooks...)))
                if description==""
                    @codegen addmethod!($this, $method) do req, id $(i.args[2]) end
                else
                    @codegen addmethod!($this, $method, $description) do req, id $(i.args[2]) end
                    description = ""
                end
            end
        else
            error("unexpected $(i.head)")
        end
    end
    esc(result)
end

function parsepipe(x::Expr)
    if x.head == :call && x.args[1] == :|
        (hooks, method) = parsepipe(x.args[2])
        (push!(hooks, x.args[3]), method)
    elseif x.head == :quote
        (Symbol[], x)
    else
        error("unexpected $x")
    end
end
