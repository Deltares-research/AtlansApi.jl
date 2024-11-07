using AtlansApi

host = get(ENV, "HOST", "127.0.0.1")
port = get(ENV, "PORT", "8081")

println("Starting server on http://$(host):$(port)")
AtlansApi.session(host, parse(Int, port))