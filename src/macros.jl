export @resource, @mixin

macro codegen(ex)
    :( push!(result.args, $(Expr(:quote, ex))) )
end

macro resource(declaration, content)
    result = Expr(:block)
    if isa(declaration, Expr)
        this   = declaration.args[1]
        super  = declaration.args[3]
        @codegen $this = Restful.Resource($(string(this)))
        @codegen Restful.addsubresource!($super, $this)
    elseif isa(declaration, Symbol)
        this = declaration
        @codegen $this = Restful.Resource($(string(this)))
    else
        error("unexpected $(declaration)")
    end

    definations = if content.head == :let
        content.args[1].args
    elseif content.head == :block
        content.args
    else
        error("unrecognized content type")
    end

    local description = ""
    for i in definations
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
            elseif key == :mixin
                @codegen Restful.addmixin!($this, $(i.args[2]))
            elseif key == :children || key == :subresources
                @codegen Restful.addsubresource!($this, $(i.args[2]))
            elseif key in setdiff(HOOKS, METHODS)
                @codegen Restful.hook!($this, $(Expr(:quote, key)), $(i.args[2]))
            else
                (hooks, method) = parsepipe(i.args[1])
                @codegen Restful.hook!($this, $method, $(Expr(:ref, :Function, hooks...)))
                if description==""
                    @codegen Restful.addmethod!($this, $method) do req, id $(i.args[2]) end
                else
                    @codegen Restful.addmethod!($this, $method, $description) do req, id $(i.args[2]) end
                    description = ""
                end
            end
        else
            error("unexpected $(i.head)")
        end
    end
    esc(result)
end

macro mixin(this, content)
    result = Expr(:block)
    @codegen $this = Restful.Mixin()
    for i in content.args
        if i.head == :line
            continue
        elseif i.head == :(=>)
            key = i.args[1].args[1]
            if key in HOOKS
                @codegen Restful.hook!($this, $(Expr(:quote, key)), $(i.args[2]))
            else
                error("no hooks called $key")
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
