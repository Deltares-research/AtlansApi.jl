function run_model(req::HTTP.Request)
    try
        data = JSON3.read(String(req.body))

        gw = data[:gw]
        features = Features(data[:geojson])

        if isa(gw, Number) && isa(features, Features)
            result = run_model(features, gw)

            return HTTP.Response(200, JSON3.write(Dict("result" => result)))
		end
	catch e
		return HTTP.Response(400, JSON3.write(Dict("error" => "Invalid input")))
    end
end


function session(host::String, port::Int)
	router = HTTP.Router() do req
		println("HTTP: \"$(req.method) $(req.target)\"")

		if req.method == "POST" && req.target == "/run"
			run_model(req)
		else
			HTTP.Response(404, "Endpoint not found")
		end
	end

	HTTP.serve(router, host, port);
end