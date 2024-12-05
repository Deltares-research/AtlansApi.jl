function run_model(req::HTTP.Request)
	try
		data = JSON3.read(String(req.body))

		gw = data[:gw]
		features = Features(data[:geojson])

		if isa(gw, Number) && isa(features, Features)
			folder_id = generate_unique_directory_id()
			initial_tif = "$OUTPUT_PATH/$folder_id/initial.tif"
			remaining_tif = "$OUTPUT_PATH/$folder_id/remaining.tif"

			result = run_model(features, gw)

			return HTTP.Response(200, JSON3.write(
				Dict("id" => folder_id, "initial" => initial_tif, "remaining" => remaining_tif),
			)
			)
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

	HTTP.serve(router, host, port)
end


function generate_unique_directory_id()
	# While id does exist generate a new id
	id = string(UUIDs.uuid4())
	while isdir("$(OUTPUT_PATH)/$id")
		id = string(UUIDs.uuid4())
	end
	mkdir("$(OUTPUT_PATH)/$id")
	return id
end
