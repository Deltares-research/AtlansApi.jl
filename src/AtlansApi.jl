module AtlansApi

using Atlans
using HTTP
using JSON3
using NCDatasets
using DataFrames
using GeoDataFrames
using GeoJSON
using GeoInterface
using Shapefile
using Rasters

abstract type AbstractFeatures end

include("base.jl")
include("utils.jl")
include("build.jl")
# include("rasterize.jl")
include("api.jl")


end # module AlansApi