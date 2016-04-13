### Resource

Resource has four properties:
- name: be used to indicate this resource. default: ""
- route: route rule of this resource, see [route](route.html). default: name
- methods: RestMethod that handles specific HTTP verb. default: RestMethod[]
- subresources: resources that belongs to this one. deault: Resource[]
- hooks: see [`hook`](hook.html)

You can use the [`@resource`](macro.html) macro to create a resource.

Resource implemented `Base.call(r::Resource, req::Request)` and `HttpServer.Server(r::Resource)`
