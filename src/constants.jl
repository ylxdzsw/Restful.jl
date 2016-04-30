const METHODS = Symbol[:GET, :POST, :PUT, :PATCH, :DELETE, :COPY, :HEAD, :OPTIONS]
const HOOKS = Symbol[METHODS; :onroute; :onhandle; :onresponse; :onreturn]
