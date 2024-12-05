import Atlans: Model # dispatch Model to AtlansApi implementation


"""
	Model(geotop::GeoTop, ahn::Raster, thickness::Raster, gw::Number)

Create a model of Atlantis SoilColumns based on the provided geographical and geological
data. SoilColumns are created for locations where surcharge thickness is available.
"""
function Model(geotop::GeoTop, ahn::Raster, thickness::Raster, gw::Number)
	params = Parameters(gw, size(thickness))

	columntype = Atlans.SoilColumn{
		GroundwaterMethod,
		ConsolidationMethod,
		PreConsolidationMethod,
		OxidationMethod,
		ShrinkageMethod,
	}
	columns = Vector{columntype}()
	index = Vector{CartesianIndex}()

	for I in CartesianIndices(thickness)
		isnan(thickness[I]) | ismissing(ahn[I]) && continue

		domain = prepare_voxelstack(
			geotop.z, ahn[I], geotop.strat[:, I], geotop.litho[:, I],
		)
		length(domain.z) == 0 && continue

		gw_column = Atlans.initialize(GroundwaterMethod, domain, params, I)
		cons_column = Atlans.initialize(
			ConsolidationMethod, PreConsolidationMethod, domain, params, I,
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
			shr_column,
		)

		Atlans.apply_preconsolidation!(col)
		push!(columns, col)
		push!(index, I)
	end

	shape = size(thickness)
	fillnan() = fill(NaN, shape)

	output = Atlans.Output(
		geotop.x, geotop.y, fillnan(), fillnan(), fillnan(), fillnan(), fillnan(),
	)
	Model(columns, index, TimeDiscretization, AdaptiveCellsize, output)
end


"""
	run_model(features::Features, groundwater::Number)

Run a model simulation using the provided features and groundwater level. This builds an
Atlantis model directly from GeoTOP data and a local AHN raster. The simulation is run for
a time period of 60 years, divided into the first 3 years ("initial") and the remaining 57
years ("remaining") and returns a `SurchargeResult` object.
"""
function run_model(features::Features, groundwater::Number)
	geotop = GeoTop(GEOTOP_URL, features.bbox)
	group_stratigraphy!(geotop)

	ahn = read_ahn(AHN_PATH, geotop.bbox)

	surcharge_thickness = rasterize_like(features, geotop, :thickness)
	model = Model(geotop, ahn, surcharge_thickness, groundwater)
	surcharge = create_surcharge(surcharge_thickness)

	additional_times = [DateTime("2023-01-01")]
	stop_time = DateTime("2080-01-01")

	simulation = Atlans.Simulation(
		model,
		tempname(),
		stop_time,
		forcings = surcharge,
		additional_times = additional_times,
	)

	results = run(simulation)
	SurchargeResult(results[1], results[end], surcharge_thickness.dims)
end


"""
	run(simulation::Atlans.Simulation)

Run the Atlans.Simulation object and return the subsidence results for "initial" and
"remaining" periods.
"""
function run(simulation::Atlans.Simulation)
	clock = simulation.clock

	results = Vector{Matrix{Float64}}()
	while Atlans.currenttime(clock) < clock.stop_time
		Atlans.advance_forcingperiod!(simulation)
		push!(results, copy(simulation.model.output.subsidence))
	end

	close(simulation.writer.dataset)
	return results
end
