module Fixtures

using AtlansApi
using JSON3
using NCDatasets
using Rasters
using Shapefile


function simple_payload()
	JSON3.write(
		Dict(
			"gw" => -1,
			"geojson" => Dict(
				"type" => "FeatureCollection",
				"features" => [
					Dict(
						"id" => "0",
						"type" => "Feature",
						"properties" => Dict("id" => 1, "dikte" => 1.2),
						"geometry" => Dict(
							"type" => "Polygon",
							"coordinates" => [
								[[210, 570], [380, 570], [210, 410], [210, 570]]
							],
						),
					),
					Dict(
						"id" => "1",
						"type" => "Feature",
						"properties" => Dict("id" => 2, "dikte" => 0.8),
						"geometry" => Dict(
							"type" => "Polygon",
							"coordinates" => [
								[[490, 390], [490, 110], [330, 250], [490, 390]]
							],
						),
					),
				],
				"crs" => Dict(
					"type" => "name",
					"properties" => Dict("name" => "urn:ogc:def:crs:EPSG::28992"),
				),
			),
		),
	)
end


function simple_features()
	data = JSON3.read(simple_payload())
	AtlansApi.Features(data[:geojson])
end


function thickness_raster()
	dims = (
		X(Projected(100.0:100:500.0; crs = EPSG(28992))),
		Y(Projected(500.0:-100:100.0; crs = EPSG(28992))),
	)
	values = [
		NaN 1.2 1.2 NaN NaN;
		NaN 1.2 NaN NaN NaN;
		NaN NaN NaN 0.8 NaN;
		NaN NaN 0.8 0.8 NaN;
		NaN NaN NaN 0.8 NaN
	]
	Raster(values, dims)
end


function geotop_nc()
	xco = yco = Vector(100.0:100:500.0)
	z = Vector(-2:0.5:-0.5)

	filename = tempname()
	ds = Dataset(filename, "c") do ds
		defDim(ds, "x", length(xco))
		defDim(ds, "y", length(yco))
		defDim(ds, "z", 4)
		AtlansApi.create_xcoord!(ds, xco)
		AtlansApi.create_ycoord!(ds, yco)
		defVar(ds, "z", z, ("z",))

		strat = defVar(ds, "strat", Int64, ("z", "y", "x"))
		lith = defVar(ds, "lithok", Int64, ("z", "y", "x"))

		strat .= [
			2 2 2 2 2; 2 2 2 2 2; 2 2 2 2 2; 1 1 1 1 1;;;
			2 2 2 2 2; 2 1 1 2 2; 2 1 1 1 2; 1 1 1 1 1;;;
			2 2 2 2 2; 2 2 1 2 2; 2 2 1 1 2; 1 1 1 1 1;;;
			2 2 2 2 2; 2 2 1 1 2; 2 2 1 1 2; 1 1 1 1 1;;;
			2 2 2 2 2; 2 2 2 2 2; 2 1 1 1 1; 1 1 1 1 1
		]
		lith .= [
			3 3 3 2 3; 1 1 2 1 1; 1 1 3 2 3; 2 3 1 2 2;;;
			1 1 2 2 1; 3 1 1 2 3; 2 3 2 2 3; 2 1 3 3 2;;;
			1 2 3 3 2; 3 1 2 2 3; 2 3 2 3 2; 3 2 2 1 3;;;
			3 3 2 1 3; 2 3 3 1 2; 3 2 1 1 3; 1 2 3 1 2;;;
			1 3 2 1 3; 3 2 1 3 3; 3 1 2 1 2; 3 2 3 1 1
		]
	end
	return filename
end


function ahn()
	dims = (
		X(Projected(100:100:500; crs = EPSG(28992))),
		Y(Projected(600:-100:100; crs = EPSG(28992))),
	)
	values = [
		0 0 0 0 0 0;
		0 0.05 -0.05 0 0 0;
		0 0 0 0 0 0;
		0 0 0 -0.02 0.02 0;
		0 0 0 0 0 0
	]
	Raster(values, dims)
end


function ahn_path()
	a = ahn()
	tempfile = "$(tempname()).tif"
	write(tempfile, a)
	return tempfile
end


function surcharge_result()
	data = ahn()
    initial = fill(0.5, size(data))
    remaining = fill(0.15, size(data))
	AtlansApi.SurchargeResult(initial, remaining, data.dims)
end


end # module AtlansApiFixtures
