@testset "run" begin
    function simulation()
        gw = -1
        features = Fixtures.simple_features()
        geotop = AtlansApi.GeoTop(Fixtures.geotop_nc(), features.bbox)
        thickness_surcharge = AtlansApi.rasterize_like(features, geotop, :thickness)
        ahn = AtlansApi.read_ahn(Fixtures.ahn_path(), geotop.bbox)

        model = AtlansApi.Model(geotop, ahn, thickness_surcharge, gw)
        surcharge = AtlansApi.create_surcharge(thickness_surcharge)

        additional_times = [DateTime("2023-01-01")]
        stop_time = DateTime("2080-01-01")

        Atlans.Simulation(
            model,
            tempname(),
            stop_time,
            forcings=surcharge,
            additional_times=additional_times
        )
    end

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

    @testset "run" begin
        simulation = simulation()
        results = AtlansApi.run(simulation)

        @test length(results) == 2
        @test size(results[1]) == (3, 5)

        result_initial = filter(!isnan, results[1])
        @test all(result_initial .≈ [
            0.1440997026
            0.0865307525
            0.1020427905
            0.1448018638
            0.1249153995
            0.0899200926
            0.3392437908
        ])
        result_secondary = filter(!isnan, results[2])
        @test all(result_secondary .≈ [
            0.0345327593
            0.0108823445
            0.0141049871
            0.0327178757
            0.0383132938
            0.0105137828
            0.0213082418
        ])
    end
end