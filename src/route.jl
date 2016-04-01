import Base.call

function Base.call(r::Resource, req::Any)
    r.methods[Symbol(req.method)](req)
end
