import Base.Meta: quot

export @resource, @mixin

macro codegen(ex)
    :( push!($(esc(:result)).args, $(quot(ex))) )
end

macro resource(declaration, content)
    result = Expr(:block)
    if isa(declaration, Expr) && declaration.head == :<:
        this, super = declaration.args
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

    for i in definations
        if i.head == :line
            @codegen $i
            continue
        end

        if i.head == :macrocall && i.args[1] isa Expr && i.args[1].head == :core && i.args[1].args[1] == Symbol("@doc")
            description = i.args[2]
            i = i.args[3]
        else
            description = ""
        end

        if i.head == :call && i.args[1] == :(=>)
            key = i.args[2].args[1]
            if key == :name
                @codegen $(this).name = $(i.args[3])
            elseif key == :route
                @codegen $(this).route = $(i.args[3])
            elseif key == :mixin
                @codegen Restful.addmixin!($this, $(i.args[3]))
            elseif key in (:children, :subresources)
                @codegen Restful.addsubresource!($this, $(i.args[3]))
            elseif key in setdiff(HOOKS, METHODS)
                @codegen Restful.hook!($this, $(quot(key)), $(i.args[3]))
            else
                (hooks, method) = parsepipe(i.args[2])
                @codegen Restful.hook!($this, $method, $(Expr(:ref, :Function, hooks...)))
                if description==""
                    @codegen Restful.addmethod!($this, $method) do req, id $(i.args[3]) end
                else
                    @codegen Restful.addmethod!($this, $method, $description) do req, id $(i.args[3]) end
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
        elseif i.head == :call && i.args[1] == :(=>)
            key = i.args[2].args[1]
            if key in HOOKS
                @codegen Restful.hook!($this, $(quot(key)), $(i.args[3]))
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
        (Union{Symbol, Expr}[], x)
    else
        error("unexpected $x")
    end
end
