function select_within_extent(geotop::Dataset, bbox::BoundingBox)
    xres = yres = 100
    zres = 0.5
    
    subset = NCDatasets.@select(
        geotop[:strat],
        $bbox.xmin <= x <= $bbox.xmax && $bbox.ymin <= y <= $bbox.ymax
    )

    x = subset[:x][:]  .+ 0.5xres # Change coordinates to cellcenters
    y = reverse(subset[:y][:] .+ 0.5yres)
    z = subset[:z][:] .+ 0.5zres
    strat = permutedims(reverse(subset[:strat][:, :, :]; dims=2), (1, 3, 2))
    litho = permutedims(reverse(subset[:lithok][:, :, :]; dims=2), (1, 3, 2))
    
    GeoTop(x, y, z, strat, litho)
end


function read_geotop(url::AbstractString, bbox::BoundingBox)
    geotop = Dataset(url) do ds
        select_within_extent(ds, bbox)
    end
end
