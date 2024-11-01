struct GeoTop
    x::Array{Int32}
    y::Array{Int32}
    z::Array{Float32}
    strat::Array{Union{Missing, Int16}}
    litho::Array{Union{Missing, Int16}}
end


function select_within_extent(geotop::Dataset, geojson::GeoJSON.FeatureCollection)
    bbox = Box(geojson)

    subset = NCDatasets.@select(
        geotop[:strat],
        $bbox.xmin <= x <= $bbox.xmax && $bbox.ymin <= y <= $bbox.ymax
    )

    x = subset[:x][:]
    y = subset[:y][:]
    z = subset[:z][:]
    strat = subset[:strat][:, :, :]
    litho = subset[:lithok][:, :, :]
    
    GeoTop(x, y, z, strat, litho)
end