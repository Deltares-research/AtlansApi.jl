"""
Temp function for testing
"""
function calc_mean(arr)
    filtered = filter(!isnan, arr)
    sum(filtered) / length(filtered)
end


function run_model(features::Features, groundwater::Number)
    geotop = read_geotop(GEOTOP_URL, features.bbox)        
    fid_raster = rasterize_like(features, geotop)

    thickness = fill(NaN, size(fid_raster))
    for fid in features.fids
        thickness[fid_raster .== fid] .= features.thickness[fid]
    end
    calc_mean(thickness) + groundwater
end