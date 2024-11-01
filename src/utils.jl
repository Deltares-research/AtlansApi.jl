struct Box
    xmin::Number
    ymin::Number
    xmax::Number
    ymax::Number
end


function Box(geojson::GeoJSON.FeatureCollection)
    extent = GeoInterface.extent(geojson)
    xbounds = extent[1]
    ybounds = extent[2]
    Box(xbounds[1], ybounds[1], xbounds[2], ybounds[2])
end


"""
    dataframe_from_features(features::GeoJSON.FeatureCollection)

Convert a GeoJSON object to a DataFrame with Polygon features.
"""
function dataframe_from_features(features::GeoJSON.FeatureCollection)
    id = Vector{Int64}()
    thickness = Vector{Float64}()
    polygons = Vector()

    for feature in features.features
        push!(id, feature.id)
        push!(thickness, feature.dikte)
        push!(polygons, createpolygon(feature.geometry.coordinates))
    end
    DataFrame(zip(id, thickness, polygons), [:id, :thickness, :geometry])
end
