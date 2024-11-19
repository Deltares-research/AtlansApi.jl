import Atlans: Model # dispatch Model to AtlansApi implementation


function Model(geotop::GeoTop, ahn::Raster, thickness::Raster, gw::Number)
end

"""
Temp function for testing
"""
function calc_mean(arr)
    filtered = filter(!isnan, arr)
    sum(filtered) / length(filtered)
end


function run_model(features::Features, groundwater::Number)
    geotop = GeoTop(GEOTOP_URL, features.bbox)        
    thickness = rasterize_like(features, geotop, :thickness)
    calc_mean(thickness) + groundwater
end
