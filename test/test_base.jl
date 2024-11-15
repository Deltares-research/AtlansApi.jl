@testset "base" begin
    @testset "Features" begin
        data = JSON3.read(Fixtures.simple_payload())

        f = AtlansApi.Features(data[:geojson])
        @test isa(f.polygon, Shapefile.Polygon)
        @test all(
            f.polygon.points .== [
                Shapefile.Point(2.0, 5.0)
                Shapefile.Point(3.0, 5.0)
                Shapefile.Point(2.0, 2.0)
                Shapefile.Point(2.0, 5.0)
                Shapefile.Point(4.0, 3.0)
                Shapefile.Point(4.0, 1.0)
                Shapefile.Point(3.0, 3.0)
                Shapefile.Point(4.0, 3.0)
            ]
        )
        @test all(f.polygon.parts .== [0, 4])
        
        @test all(f.fids .== [1, 2])
        @test all(f.thickness .== [1.2, 0.8])
        
        @test isa(f.bbox, AtlansApi.BoundingBox)
        @test f.bbox.xmin == 2
        @test f.bbox.ymin == 1
        @test f.bbox.xmax == 4
        @test f.bbox.ymax == 5
    end
end