import Base: write # Dispatch to write surcharge results to a tif file


"""
	GeoTop(url::AbstractString, bbox::BoundingBox)

Read GeoTop data directly from the Opendap server for a selected area in a bounding box.
"""
function GeoTop(url::AbstractString, bbox::BoundingBox)
	geotop = Dataset(url) do ds
		GeoTop(ds, bbox)
	end
end


"""
	GeoTop(geotop::Dataset, bbox::BoundingBox)

Select GeoTop data for a selected bounding box from a NCDatasets.Dataset.
"""
function GeoTop(geotop::Dataset, bbox::BoundingBox)
	xres, yres = GeotopResolution

	xmin = bbox.xmin - xres
	ymin = bbox.ymin - yres

	subset = NCDatasets.@select(
		geotop[:strat], $xmin < x < $bbox.xmax && $ymin < y < $bbox.ymax
	)

	x = subset[:x][:] .+ 0.5xres # Change coordinates to cellcenters
	y = reverse(subset[:y][:] .+ 0.5yres)
	z = subset[:z][:] .+ 0.5DzGeotop
	strat = permutedims(reverse(subset[:strat][:, :, :]; dims = 2), (1, 3, 2))
	litho = permutedims(reverse(subset[:lithok][:, :, :]; dims = 2), (1, 3, 2))

	bbox = BoundingBox(
		minimum(x) - 0.5xres,
		minimum(y) - 0.5yres,
		maximum(x) + 0.5xres,
		maximum(y) + 0.5yres,
	)

	GeoTop(x, y, z, strat, litho, bbox)
end


"""
	read_ahn(path::AbstractString, bbox::BoundingBox)

Read a 100x100 meter resolution tif of AHN data.
"""
function read_ahn(path::AbstractString, bbox::BoundingBox)
	xres = yres = 100
	ahn = Raster(path)
	xcenters = ahn.dims[1] .+ 0.5xres
	ycenters = ahn.dims[2] .- 0.5yres
	new_dims = (
		X(Projected(xcenters[1]:100:xcenters[end]; crs = EPSG(28992))),
		Y(Projected(ycenters[1]:-100:ycenters[end]; crs = EPSG(28992))),
	)
	ahn = Raster(ahn.data, new_dims)
	return ahn[X(bbox.xmin .. bbox.xmax), Y(bbox.ymin .. bbox.ymax)]
end


"""
	write(
		result::SurchargeResult,
		path_initial::AbstractString,
		path_remaining::AbstractString
	)

Write the initial and remaining surcharge results to tif files.
"""
function write(
	result::SurchargeResult,
	path_initial::AbstractString,
	path_remaining::AbstractString,
)
	write(path_initial, Raster(result.initial, result.dims))
	write(path_remaining, Raster(result.remaining, result.dims))
end
