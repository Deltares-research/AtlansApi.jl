@testset "base" begin
    @testset "Features" begin
        data = JSON3.read(Fixtures.simple_payload())

        f = AtlansApi.Features(data[:geojson])
        @test isa(f.polygon, Shapefile.Polygon)
        @test all(
            f.polygon.points .== [
                Shapefile.Point(200.0, 500.0)
                Shapefile.Point(300.0, 500.0)
                Shapefile.Point(200.0, 200.0)
                Shapefile.Point(200.0, 500.0)
                Shapefile.Point(400.0, 300.0)
                Shapefile.Point(400.0, 100.0)
                Shapefile.Point(300.0, 300.0)
                Shapefile.Point(400.0, 300.0)
            ]
        )
        @test all(f.polygon.parts .== [0, 4])
        
        @test all(f.fids .== [1, 2])
        @test all(f.thickness .== [1.2, 0.8])
        
        @test isa(f.bbox, AtlansApi.BoundingBox)
        @test f.bbox.xmin == 200
        @test f.bbox.ymin == 100
        @test f.bbox.xmax == 400
        @test f.bbox.ymax == 500
    end
end