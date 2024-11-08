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


"""
    read_geotop(url::AbstractString, bbox::BoundingBox)

Read GeoTop data directly from the Opendap server for a selected area in a bounding box.
"""
function read_geotop(url::AbstractString, bbox::BoundingBox)
    geotop = Dataset(url) do ds
        select_within_extent(ds, bbox)
    end
end


function create_xcoord!(ds::Dataset, x::Vector{Float64})
    defVar(
        ds,
        "x",
        x,
        ("x",),
        attrib=["standard_name" => "projection_x_coordinate", "axis" => "X"],
    )
end


function create_ycoord!(ds::Dataset, y::Vector{Float64})
    defVar(
        ds,
        "y",
        y,
        ("y",),
        attrib=["standard_name" => "projection_y_coordinate", "axis" => "Y"],
    )
end


"""
    surcharge_netcdf(thickness::Raster)

Create a temporary NetCDF Dataset for the surcharge to apply in Atlantis based on a
Raster dataset of the surcharge thickness.
"""
function surcharge_netcdf(thickness::Raster)
    xco = Vector(thickness.dims[1].val)
    yco = Vector(thickness.dims[2].val)
    
    filename = tempname()
    ds = Dataset(filename, "c") do ds
        defDim(ds, "x", length(xco))
        defDim(ds, "y", length(yco))
        defDim(ds, "layer", 1)
        defDim(ds, "time", 1)
        create_xcoord!(ds, xco)
        create_ycoord!(ds, yco)
        defVar(ds, "layer", [1], ("layer",))
        defVar(ds, "time", [DateTime("2020-01-01")], ("time",))

        lithology = defVar(ds, "lithology", Int64, ("x", "y", "layer", "time"))
        surcharge = defVar(ds, "thickness", Float64, ("x", "y", "layer", "time"))

        lithology .= fill(RaisedSand, (length(xco), length(yco), 1, 1))
        surcharge .= reshape(thickness.data, (length(xco), length(yco), 1, 1))
    end
    return filename
end


"""
    create_surcharge(thickness::Raster)

Create an Atlantis `Surcharge` based on the Raster dataset with the surcharge thickness
to apply.
"""
function create_surcharge(thickness::Raster)
    path_surcharge = AtlansApi.surcharge_netcdf(thickness)
    
    reader = Atlans.prepare_reader(path_surcharge)
    size = Atlans.xyz_size(reader)
    
    Atlans.Surcharge(
        Array{Union{Missing, Int64}}(missing, size),
        Array{Union{Missing, Float64}}(missing, size),
        reader,
        ParamTable
    )
end
