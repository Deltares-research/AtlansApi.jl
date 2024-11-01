function select_within_extent(geotop::Dataset, bbox::BoundingBox)
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


function read_geotop(url::AbstractString, bbox::BoundingBox)
    geotop = Dataset(url) do ds
        select_within_extent(ds, bbox)
    end
end