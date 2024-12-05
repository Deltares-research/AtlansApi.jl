"""
	rasterize_like(features::GeoJSON.FeatureCollection, geotop::GeoTop; kw...)

Rasterize the "fids" of an incoming geojson with polygons within the 2D raster extent of
the modelling area of GeoTop.
"""
function rasterize_like(features::Features, geotop::GeoTop; kw...)
	rings = features_to_rings(features)
	target = get_target_raster(geotop)
	rasterize!(last, target, rings; fill = features.fids, kw...)
end


"""
	rasterize_like(features::GeoJSON.FeatureCollection, geotop::GeoTop, field::Symbol)

Rasterize a field of an incoming geojson with polygons within the 2D raster extent of
the modelling area of GeoTop.
"""
function rasterize_like(features::Features, geotop::GeoTop, field::Symbol)
	fid_raster = rasterize_like(features, geotop; boundary = :touches)

	field_values = getproperty(features, field)
	field_raster = fill(NaN, size(fid_raster))
	for fid in features.fids
		field_raster[fid_raster.==fid] .= field_values[fid]
	end
	Raster(field_raster, fid_raster.dims)
end


function get_target_raster(geotop::GeoTop)
	dimz = (
		X(
			Projected(
				geotop.x[1]:100:geotop.x[end]; sampling = Intervals(), crs = EPSG(28992),
			),
		),
		Y(
			Projected(
				geotop.y[1]:-100:geotop.y[end]; sampling = Intervals(), crs = EPSG(28992),
			),
		),
	)
	zeros(UInt32, dimz; missingval = UInt32(0))
end


function features_to_rings(features::Features)
	collect(GeoInterface.getring(features.polygon))
end
