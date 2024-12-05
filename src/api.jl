"""
	run_model(req::HTTP.Request)

Process an HTTP request to run an Atlantis model simulation for surcharge calculations
based on the provided input data.

# Request JSON Structure
- `gw`: A numerical value representing the groundwater level.
- `geojson`: A GeoJSON object representing the geographical features.

# Response JSON Structure
- `id`: A unique identifier for the generated directory.
- `initial`: The file path to the initial TIFF file.
- `remaining`: The file path to the remaining TIFF file.

# Errors
- Returns a 400 HTTP response with an error message if the input is invalid.
"""
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
			write(result, initial_tif, remaining_tif)

			return HTTP.Response(200, JSON3.write(
				Dict(
					"id" => folder_id,
					"initial" => initial_tif,
					"remaining" => remaining_tif,
				),
			))
		end
	catch e
		return HTTP.Response(400, JSON3.write(Dict("error" => "Invalid input")))
	end
end


"""
	session(host::String, port::Int)

Start an HTTP server session to listen for incoming requests to run Atlantis model simulations.
"""
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


"""
	generate_unique_directory_id()

Helper function to generate a unique directory id-hash for different API calls to store
model output tifs.
"""
function generate_unique_directory_id()
	# While id does exist generate a new id
	id = string(UUIDs.uuid4())
	while isdir("$(OUTPUT_PATH)/$id")
		id = string(UUIDs.uuid4())
	end
	mkdir("$(OUTPUT_PATH)/$id")
	return id
end
