function run_model(req::HTTP.Request)
    try
        data = JSON3.read(String(req.body))

        gw = data[:gw]
        features = Features(data[:geojson])

        if isa(gw, Number) && isa(features, Features)
            result = run_model(features, gw)

            return HTTP.Response(200, JSON3.write(Dict("result" => result)))
        else
			return HTTP.Response(
                400, JSON3.write(Dict("error" => "Input must be numeric"))
            )
		end
	catch e
		return HTTP.Response(400, JSON3.write(Dict("error" => "Invalid input")))
    end
end


function session()
	router = HTTP.Router() do req
		if req.method == "POST" && req.target == "/run"
			run_model(req)
		else
			HTTP.Response(404, "Endpoint not found")
		end
	end
	# Start de server op poort 8081
	HTTP.serve(router, "127.0.0.1", 8081)
end
