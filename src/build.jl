"""
    GeoTop(geotop::Dataset, bbox::BoundingBox)

Select GeoTop data for a selected bounding box from a NCDatasets.Dataset.
"""
function GeoTop(geotop::Dataset, bbox::BoundingBox)
    xres, yres = GeotopResolution

    xmin = bbox.xmin - xres
    ymin = bbox.ymin - yres

    subset = NCDatasets.@select(
        geotop[:strat], $xmin < x < $bbox.xmax && $ymin < y < $bbox.ymax
    )

    x = subset[:x][:]  .+ 0.5xres # Change coordinates to cellcenters
    y = reverse(subset[:y][:] .+ 0.5yres)
    z = subset[:z][:] .+ 0.5DzGeotop
    strat = permutedims(reverse(subset[:strat][:, :, :]; dims=2), (1, 3, 2))
    litho = permutedims(reverse(subset[:lithok][:, :, :]; dims=2), (1, 3, 2))
    
    bbox = BoundingBox(
        minimum(x) - 0.5xres,
        minimum(y) - 0.5yres,
        maximum(x) + 0.5xres,
        maximum(y) + 0.5yres,
    )

    GeoTop(x, y, z, strat, litho, bbox)
end


"""
    GeoTop(url::AbstractString, bbox::BoundingBox)

Read GeoTop data directly from the Opendap server for a selected area in a bounding box.
"""
function GeoTop(url::AbstractString, bbox::BoundingBox)
    geotop = Dataset(url) do ds
        GeoTop(ds, bbox)
    end
end


function group_stratigraphy!(geotop::GeoTop)
    for unit in HoloceneUnits
        replace!(geotop.strat, unit => 1)
    end
    for unit in unique(geotop.strat)
        ismissing(unit) | unit == 1 && continue
        replace!(geotop.strat, unit => 2)
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
to apply. Returns an `Atlans.Forcings` object that contains the surcharge and which can
be passed to an Atlantis model simulation.
"""
function create_surcharge(thickness::Raster)
    path_surcharge = AtlansApi.surcharge_netcdf(thickness)
    
    reader = Atlans.prepare_reader(path_surcharge)
    size = Atlans.xyz_size(reader)
    
    surcharge = Atlans.Surcharge(
        Array{Union{Missing, Int64}}(missing, size),
        Array{Union{Missing, Float64}}(missing, size),
        reader,
        ParamTable
    )
    Atlans.Forcings(surcharge=surcharge)
end


"""
    read_ahn(path::AbstractString, bbox::BoundingBox)

Read a 100x100 meter resolution tif of AHN data.
"""
function read_ahn(path::AbstractString, bbox::BoundingBox)
    xres = yres = 100
    ahn = Raster(path)
    xcenters = ahn.dims[1] .+ 0.5xres
    ycenters = ahn.dims[2] .- 0.5yres
    new_dims = (
        X(Projected(xcenters[1]:100:xcenters[end]; crs=EPSG(28992))),
        Y(Projected(ycenters[1]:-100:ycenters[end]; crs=EPSG(28992)))
    )
    ahn = Raster(ahn.data, new_dims)
    return ahn[X(bbox.xmin .. bbox.xmax), Y(bbox.ymin .. bbox.ymax)]
end


function shift_down(thickness, strat, litho, surface, modelbase)
    ztop = modelbase .+ cumsum(thickness)
    split_idx = findlast(ztop .< surface)

    new_thickness_voxel = surface - ztop[split_idx]

    if new_thickness_voxel > 0.1
        split_idx += 1
        thickness[split_idx] = new_thickness_voxel
    else
        thickness[split_idx] += new_thickness_voxel
    end
    
    thickness = thickness[1:split_idx]
    strat = strat[1:split_idx]
    litho = litho[1:split_idx]

    return thickness, strat, litho    
end


function shift_up(thickness, strat, litho, surface, modelbase)
    top_idx = length(thickness)
    extra_thickness = surface - (modelbase + sum(thickness))

    if extra_thickness > 0.1
        push!(thickness, extra_thickness)
        push!(strat, strat[top_idx])
        push!(litho, litho[top_idx])
    else
        thickness[top_idx] += extra_thickness
    end
    return thickness, strat, litho
end


function add_antropogenic(thickness, strat, litho, difference)
    antropogenic = 0
    holocene = 1
    push!(thickness, difference)
    push!(strat, holocene)
    push!(litho, antropogenic)
    return thickness, strat, litho
end


"""
    prepare_voxelstack(
        z::Vector{Number},
        surface::Number,
        strat::Vector{Number},
        litho::Vector{Number}
    )

Create an Atlantis `VerticalDomain` from a voxelstack of GeoTOP. This checks the depths
against the surface level elevation and corrects voxel thicknesses that are above or below
the surface level. If the surface level elevation is more than 2 meters higher than the
elevation of the highest voxel, a layer of antropogenic material is added with the appropriate
thickness.

# Arguments:
- `z`: NAP Depth of each voxel.
- `surface`: Surface level elevation in NAP.
- `strat`: Stratigraphic unit of each voxel.
- `litho`: Lithology of each voxel.
"""
function prepare_voxelstack(z, surface, strat, litho)
    base_idx = findfirst(.!ismissing.(strat))
    top_idx = findlast(.!ismissing.(strat))

    modelbase = domainbase = z[base_idx] - 0.5DzGeotop
    thickness = fill(DzGeotop, length(base_idx:top_idx))
    strat = strat[base_idx:top_idx]
    litho = litho[base_idx:top_idx]

    ztop = modelbase + sum(thickness)

    surface_difference = surface - ztop

    if surface_difference < 0
        thickness, strat, litho = shift_down(
            thickness, strat, litho, surface, modelbase
        )
    elseif 2 > surface_difference > 0
        thickness, strat, litho = shift_up(thickness, strat, litho, surface, modelbase)
    elseif surface_difference > 2
        thickness, strat, litho = add_antropogenic(
            thickness, strat, litho, surface_difference
        )
    end
    Atlans.prepare_domain(
        domainbase, modelbase, surface, thickness, AdaptiveCellsize.Δzmax, strat, litho
    )
end


domainbase(domain::Atlans.VerticalDomain) = domain.z[1] - 0.5 * domain.Δz[1]
