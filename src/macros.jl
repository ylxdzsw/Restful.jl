export @resource

macro add(ex)
    a = :( push!(result.args, :()) )
    a.args[3].args[1] = ex
    a
end

macro resource(declaration, content)
    result = Expr(:block)
    if isa(declaration, Expr)
        this   = declaration.args[1]
        super  = declaration.args[3]
        @add $this = Resource()
        @add addsubresource($super, $this)
    elseif isa(declaration, Symbol)
        this = declaration
        @add $declaration = Resource()
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
            if i.args[1].args[1] == :name
                @add $(this).name = $(i.args[2])
            elseif i.args[1].args[1] == :route
                @add $(this).route = $(i.args[2])
            else
                if description==""
                    @add addmethod($this, $(i.args[1])) do req, id $(i.args[2]) end
                else
                    @add addmethod($this, $(i.args[1]), $description) do req, id $(i.args[2]) end
                    description = ""
                end
            end
        else
            error("unexpected $(i.head)")
        end
    end
    esc(result)
end
