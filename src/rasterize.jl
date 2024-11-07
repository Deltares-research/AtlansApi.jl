"""
    rasterize_like(features::GeoJSON.FeatureCollection, geotop::GeoTop)

Rasterize the "fids" of an incoming geojson with polygons within the 2D raster extent of
the modelling area of GeoTop.
"""
function rasterize_like(features::Features, geotop::GeoTop)
    rings = features_to_rings(features)
    target = get_target_raster(geotop)
    rasterize!(last, target, rings; fill=features.fids)
end


function rasterize_like(features::Features, geotop::GeoTop, field::Symbol)
    fid_raster = rasterize_like(features, geotop)

    field_values = getproperty(features, field)
    field_raster = fill(NaN, size(fid_raster))
    for fid in features.fids
        field_raster[fid_raster .== fid] .= field_values[fid]
    end
    return field_raster
end


function get_target_raster(geotop::GeoTop)
    dimz = (
        Y(
            Projected(
                geotop.y[1]:100:geotop.y[end]; crs=EPSG(28992)
            )
        ),
        X(
            Projected(
                geotop.x[1]:100:geotop.x[end]; crs=EPSG(28992)
            )
        )
    )
    zeros(UInt32, dimz; missingval=UInt32(0))
end


function features_to_rings(features::Features)
    collect(GeoInterface.getring(features.polygon))
end
