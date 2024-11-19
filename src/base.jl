struct BoundingBox
    xmin::Number
    ymin::Number
    xmax::Number
    ymax::Number
end


struct Features <: AbstractSpatial
    polygon::Any
    fids::Vector{Number}
    thickness::Vector{Number}
    bbox::BoundingBox
end


struct GeoTop <: AbstractSpatial
    x::Array{Real}
    y::Array{Real}
    z::Array{Real}
    strat::Array{Union{Missing, Real}}
    litho::Array{Union{Missing, Real}}
    bbox::BoundingBox
end


function BoundingBox(points::Vector{Shapefile.Point})
    xmin = minimum(p.x for p in points)
    xmax = maximum(p.x for p in points)
    ymin = minimum(p.y for p in points)
    ymax = maximum(p.y for p in points)
    BoundingBox(xmin, ymin, xmax, ymax)
end


function Features(features::JSON3.Object)
    points = Vector{Shapefile.Point}()
    parts = Vector{Int32}()
    thickness = Vector{Number}()
    fid = Vector{Number}()

    pa = 0
    for feature in features[:features]
        pts = [Shapefile.Point(p[1], p[2]) for p in feature.geometry.coordinates[1]]
        append!(points, pts)
        push!(parts, pa)
        push!(fid, feature.properties[:id])
        push!(thickness, feature.properties[:dikte])
        pa += length(pts)
    end

    bbox = BoundingBox(points)

    pol = Shapefile.Polygon(
        Shapefile.Rect(bbox.xmin, bbox.ymin, bbox.xmax, bbox.ymax), parts, points
    )

    Features(pol, fid, thickness, bbox)
end
