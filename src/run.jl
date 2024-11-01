"""
Temp function for testing
"""
function calc_mean(arr)
    filter!(!isnan, arr)
    sum(arr) / length(arr)
end


function run_model(features::Features, groundwater::Number)
    geotop = read_geotop(GEOTOP_URL, features.bbox)        
    fid_raster = rasterize_like(features, geotop)

    thickness = fill(NaN, size(pol_raster))
    for fid in features.fids
        thickness[pol_raster .== fid] .= features.thickness[fid]
    end
    calc_mean(thickness)
end