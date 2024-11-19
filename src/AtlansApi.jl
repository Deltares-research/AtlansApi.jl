module AtlansApi

using Atlans
using ArchGDAL
using DataFrames
using Dates
using HTTP
using JSON3
using NCDatasets
using GeoInterface
using Shapefile
using Rasters

abstract type AbstractSpatial end # Means subtypes will have field :bbox

include("example/sample.jl") 
include("constants.jl")

# GeoTOP constants
const GEOTOP_URL = raw"https://dinodata.nl/opendap/GeoTOP/geotop.nc"
const GeotopResolution = (100, 100) # x, y
const DzGeotop = 0.5 # z

# Atlantis constants
const AdaptiveCellsize = Atlans.AdaptiveCellsize(0.25, 0.01) # Δzmax, split_tolerance
const TimeDiscretization = Atlans.ExponentialTimeStepper(1.0, 2) # start day, multiplier
const ConsolidationMethod = Atlans.DrainingAbcIsotache
const PreConsolidationMethod = Atlans.Preconsolidation
const OxidationMethod = Atlans.NullOxidation # Ignore oxidation process
const ShrinkageMethod = Atlans.NullShrinkage # Ignore shrinkage process
const ParamTable = Dict(
    :ocr => Dict(zip(KEYS, OCR)),
    :drainage_Factor => Dict(zip(KEYS, DRAINAGE_FACTOR)),
    :a => Dict(zip(KEYS, A_ISOTACHE)),
    :b => Dict(zip(KEYS, B_ISOTACHE)),
    :c => Dict(zip(KEYS, C_ISOTACHE)),
    :gamma_wet => Dict(zip(KEYS, GAMMA_WET)),
    :gamma_dry => Dict(zip(KEYS, GAMMA_DRY)),
    :c_v => Dict(zip(KEYS, C_V))
)

# API constants
const RaisedSand = 99

include("base.jl")
include("build.jl")
include("rasterize.jl")
include("run.jl")
include("api.jl")


end # module AlansApi