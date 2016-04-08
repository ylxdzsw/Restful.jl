const METHODS = Symbol[:GET, :POST, :PUT, :PATCH, :DELETE, :COPY, :HEAD, :OPTIONS, :LINK, :UNLINK, :PURGE, :LOCK, :UNLOCK, :PROPFIND, :VIEW]
const HOOKS = Symbol[METHODS; :preroute; :onresponse; :onreturn]
