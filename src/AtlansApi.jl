module AtlansApi

using Atlans
using DataFrames
using Dates
using HTTP
using JSON3
using NCDatasets
using GeoInterface
using Shapefile
using Rasters

abstract type AbstractFeatures end

include("constants.jl")

const GEOTOP_URL = raw"https://dinodata.nl/opendap/GeoTOP/geotop.nc"
const RaisedSand = 99

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

include("example/sample.jl")
include("base.jl")
include("build.jl")
include("rasterize.jl")
include("run.jl")
include("api.jl")


end # module AlansApi