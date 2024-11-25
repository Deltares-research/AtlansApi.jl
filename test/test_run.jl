@testset "run" begin
    @testset "Model" begin
        gw = -1
        features = Fixtures.simple_features()
        geotop = AtlansApi.GeoTop(Fixtures.geotop_nc(), features.bbox)
        thickness_surcharge = AtlansApi.rasterize_like(features, geotop, :thickness)
        ahn = AtlansApi.read_ahn(Fixtures.ahn_path(), geotop.bbox)

        model = AtlansApi.Model(geotop, ahn, thickness_surcharge, gw)

        @test isa(
            model,
            Atlans.Model{
                Atlans.HydrostaticGroundwater,
                Atlans.DrainingAbcIsotache,
                Atlans.OverConsolidationRatio,
                Atlans.NullOxidation,
                Atlans.NullShrinkage,
                Atlans.ExponentialTimeStepper{Int64},
                Atlans.AdaptiveCellsize,
            }
        )
        @test length(model.columns) == 7
        @test all(
            model.index .== [
                CartesianIndex(1, 1),
                CartesianIndex(2, 1),
                CartesianIndex(1, 2),
                CartesianIndex(3, 3),
                CartesianIndex(2, 4),
                CartesianIndex(3, 4),
                CartesianIndex(3, 5),
            ]
        )
    end
end