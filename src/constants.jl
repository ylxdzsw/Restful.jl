const METHODS = [:GET, :POST, :PUT, :PATCH, :DELETE, :COPY, :HEAD, :OPTIONS]
const HOOKS = [METHODS; :onroute; :onhandle; :onresponse; :onreturn]
