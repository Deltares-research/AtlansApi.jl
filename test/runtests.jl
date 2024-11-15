using Revise
using AtlansApi
using Atlans
using JSON3
using Rasters
using Shapefile
using Test

include("fixtures.jl")

include("test_base.jl")
include("test_build.jl")
include("test_rasterize.jl")
