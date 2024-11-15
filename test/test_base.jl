@testset "base" begin
    @testset "Features" begin
        data = JSON3.read(Fixtures.simple_payload())

        f = AtlansApi.Features(data[:geojson])
        @test isa(f.polygon, Shapefile.Polygon)
        @test all(
            f.polygon.points .== [
                Shapefile.Point(210.0, 570.0)
                Shapefile.Point(380.0, 570.0)
                Shapefile.Point(210.0, 410.0)
                Shapefile.Point(210.0, 570.0)
                Shapefile.Point(490.0, 390.0)
                Shapefile.Point(490.0, 110.0)
                Shapefile.Point(330.0, 250.0)
                Shapefile.Point(490.0, 390.0)
            ]
        )
        @test all(f.polygon.parts .== [0, 4])
        
        @test all(f.fids .== [1, 2])
        @test all(f.thickness .== [1.2, 0.8])
        
        @test isa(f.bbox, AtlansApi.BoundingBox)
        @test f.bbox.xmin == 210
        @test f.bbox.ymin == 110
        @test f.bbox.xmax == 490
        @test f.bbox.ymax == 570
    end
end