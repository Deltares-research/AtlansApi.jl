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
