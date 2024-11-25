import Atlans: Model # dispatch Model to AtlansApi implementation


function Model(geotop::GeoTop, ahn::Raster, thickness::Raster, gw::Number)
    params = Parameters(gw, size(thickness))
    
    columntype = Atlans.SoilColumn{
        GroundwaterMethod,
        ConsolidationMethod,
        PreConsolidationMethod,
        OxidationMethod,
        ShrinkageMethod
    }    
    columns = Vector{columntype}()
    index = Vector{CartesianIndex}()
    
    for I in CartesianIndices(thickness)
        isnan(thickness[I]) | ismissing(ahn[I]) && continue

        domain = prepare_voxelstack(
            geotop.z, ahn[I], geotop.strat[:, I], geotop.litho[:, I]
        )
        length(domain.z) == 0 && continue

        gw_column = Atlans.initialize(GroundwaterMethod, domain, params, I)
        cons_column = Atlans.initialize(
            ConsolidationMethod, PreConsolidationMethod, domain, params, I
        )
        ox_column = Atlans.initialize(OxidationMethod, domain, params, I)
        shr_column = Atlans.initialize(ShrinkageMethod, domain, params, I)

        col = Atlans.SoilColumn(
            domainbase(domain),
            geotop.x[I[1]],
            geotop.y[I[2]],
            domain.z,
            domain.Δz,
            gw_column,
            cons_column,
            ox_column,
            shr_column
        )

        Atlans.apply_preconsolidation!(col)
        push!(columns, col)
        push!(index, I)
    end

    shape = size(thickness)
    fillnan() = fill(NaN, shape)

    output = Atlans.Output(
        geotop.x, geotop.y, fillnan(), fillnan(), fillnan(), fillnan(), fillnan()
    )
    Model(columns, index, TimeDiscretization, AdaptiveCellsize, output)
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
