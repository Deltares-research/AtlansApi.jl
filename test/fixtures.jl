module Fixtures

using AtlansApi
using JSON3
using NCDatasets
using Rasters
using Shapefile


function simple_payload()
    JSON3.write(
        Dict(
            "gw" => -1,
            "geojson" => Dict(
                "type" => "FeatureCollection",
                "features" => [
                    Dict(
                        "id" => "0",
                        "type" => "Feature",
                        "properties" => Dict("id" => 1, "dikte" => 1.2),
                        "geometry" => Dict(
                            "type" => "Polygon",
                            "coordinates" => [[[2, 5], [3, 5], [2, 2], [2, 5]]]
                        )
                    ),
                    Dict(
                        "id" => "1",
                        "type" => "Feature",
                        "properties" => Dict("id" => 2, "dikte" => 0.8),
                        "geometry" => Dict(
                            "type" => "Polygon",
                            "coordinates" => [[[4, 3], [4, 1], [3, 3], [4, 3]]]
                        )
                    ),
                ],
                "crs" => Dict(
                    "type" => "name",
                    "properties" => Dict("name" => "urn:ogc:def:crs:EPSG::28992")
                )
            )
        )
    )
end


function simple_features()
    data = JSON3.read(simple_payload())
    AtlansApi.Features(data[:geojson])
end


function thickness_raster()
    dims = (
        X(Projected(1.:1:5.; crs=EPSG(28992))),
        Y(Projected(5.:-1:1.; crs=EPSG(28992)))
    )
    values = [
        NaN 1.2 1.2 NaN NaN;
        NaN 1.2 NaN NaN NaN;
        NaN NaN NaN 0.8 NaN;
        NaN NaN 0.8 0.8 NaN;
        NaN NaN NaN 0.8 NaN;
    ]
    Raster(values, dims)
end


function simple_nc()
    raster = thickness_raster()
    xco = Vector(raster.dims[1].val)
    yco = Vector(raster.dims[2].val)

    filename = tempname()
    ds = Dataset(filename, "c") do ds
        defDim(ds, "x", length(xco))
        defDim(ds, "y", length(yco))
        defDim(ds, "layer", 1)
        AtlansApi.create_xcoord!(ds, xco)
        AtlansApi.create_ycoord!(ds, yco)
        defVar(ds, "layer", [1], ("layer",))
        
        lithology = defVar(ds, "lithology", Int64, ("x", "y", "layer"))
        lithology .= 1
    end
    return filename
end

end # module AtlansApiFixtures