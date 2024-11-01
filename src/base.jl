struct BoundingBox
    xmin::Number
    ymin::Number
    xmax::Number
    ymax::Number
end


struct Features <: AbstractFeatures
    polygon::Any
    fids::Vector{Number}
    thickness::Vector{Number}
    bbox::BoundingBox
end


struct GeoTop
    x::Array{Number}
    y::Array{Number}
    z::Array{Number}
    strat::Array{Union{Missing, Int16}}
    litho::Array{Union{Missing, Int16}}
end


function BoundingBox(geojson)
    extent = GeoInterface.extent(geojson)
    xbounds = extent[1]
    ybounds = extent[2]
    BoundingBox(xbounds[1], ybounds[1], xbounds[2], ybounds[2])
end


function Features(features::JSON3.Object)
    features = GeoJSON.read(JSON3.write(features))

    bbox = BoundingBox(features)
    
    points = Vector{Shapefile.Point}()
    thickness = Vector{Number}()
    fid = Vector{Number}()
    parts = Vector{Int32}()

    pa = 0
    for feature in collect(features)
        pts = [Shapefile.Point(p[1], p[2]) for p in feature.geometry.coordinates[1]]
        append!(points, pts)
        push!(parts, pa)
        pa += length(pts)
    end

    pol = Shapefile.Polygon(
        Shapefile.Rect(bbox.xmin, bbox.ymin, bbox.xmax, bbox.ymax), parts, points
    )
    Features(pol, fid, thickness, bbox)
end
