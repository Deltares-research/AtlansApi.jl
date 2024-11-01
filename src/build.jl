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