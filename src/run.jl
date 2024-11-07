using Atlans: Model # dispatch Model to AtlansApi implementation

const AdaptiveCellsize = Atlans.AdaptiveCellsize(0.25, 0.01) # Δzmax, split_tolerance
const TimeDiscretization = Atlans.ExponentialTimeStepper(1.0, 2) # start day, multiplier


"""
Temp function for testing
"""
function calc_mean(arr)
    filtered = filter(!isnan, arr)
    sum(filtered) / length(filtered)
end


function run_model(features::Features, groundwater::Number)
    geotop = read_geotop(GEOTOP_URL, features.bbox)        
    thickness = rasterize_like(features, geotop, :thickness)
    calc_mean(thickness) + groundwater
end
