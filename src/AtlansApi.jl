module AtlansApi

using Atlans
using HTTP
using JSON3
using NCDatasets
using DataFrames
using GeoDataFrames
using GeoInterface
using Shapefile
using Rasters

abstract type AbstractFeatures end

const GEOTOP_URL = raw"https://dinodata.nl/opendap/GeoTOP/geotop.nc"

include("base.jl")
include("build.jl")
include("rasterize.jl")
include("run.jl")
include("api.jl")


end # module AlansApi