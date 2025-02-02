@testset "build" begin
    function voxelstack_z_negative()
        z = [-2.25, -1.75, -1.25, -0.75, -0.25]
        strat = [2, 2, 2, 1, 1]
        litho = [3, 2, 1, 3, 2]
        return z, strat, litho
    end

    function voxelstack_z_positive()
        z = [0.25, 0.75, 1.25, 1.75, 2.25]
        strat = [2, 2, 2, 1, 1]
        litho = [3, 2, 1, 3, 2]
        return z, strat, litho
    end

    @testset "create_surcharge" begin
        t = Fixtures.thickness_raster()

        forcings = AtlansApi.create_surcharge(t)
        @test isa(forcings, Atlans.Forcings)
        @test isnothing(forcings.deep_subsidence)
        @test isnothing(forcings.stage_indexation)
        @test isnothing(forcings.stage_change)
        @test isnothing(forcings.aquifer_head)
        @test isnothing(forcings.temperature)
        
        sur = forcings.surcharge
        @test all(ismissing.(sur.lithology))
        @test all(ismissing.(sur.thickness))
        @test isa(sur.reader, Atlans.Reader)
        @test isa(sur.lookup, Dict{Symbol, Dict{Tuple{Int64, Int64}}})
        @test size(sur.reader.dataset[:lithology]) == (5, 5, 1, 1)
        @test size(sur.reader.dataset[:thickness]) == (5, 5, 1, 1)
        @test all(
            filter(!isnan, t.data) .== filter(!isnan, sur.reader.dataset[:thickness])
        )
    end

    @testset "group_stratigraphy" begin
        gtp = AtlansApi.GeoTop(
            [1],
            [2],
            [3],
            [5020 3100 1100; 3025 1090 missing],
            [1 2; 2 missing],
            AtlansApi.BoundingBox(1, 1, 3, 3)
        )
        AtlansApi.group_stratigraphy!(gtp)
        @test all(skipmissing(gtp.strat) .== skipmissing([2 2 1; 2 1 missing]))
    end

    @testset "shift_down" begin
        # Test columns with negative depth values
        modelbase = -2.5
        
        surface = -0.05
        _, strat, litho = voxelstack_z_negative()
        Δz = fill(0.5, length(strat))

        Δz, strat, litho = AtlansApi.shift_down(Δz, strat, litho, surface, modelbase)
        @test all(Δz .≈ [0.5, 0.5, 0.5, 0.5, 0.45])
        @test all(strat .== [2, 2, 2, 1, 1])
        @test all(litho .== [3, 2, 1, 3, 2])

        surface = -0.47
        _, strat, litho = voxelstack_z_negative()
        Δz = fill(0.5, length(strat))

        Δz, strat, litho = AtlansApi.shift_down(Δz, strat, litho, surface, modelbase)
        @test all(Δz .≈ [0.5, 0.5, 0.5, 0.53])
        @test all(strat .== [2, 2, 2, 1])
        @test all(litho .== [3, 2, 1, 3])

        # Test columns with positive depth values
        modelbase = 0

        surface = 2.3
        _, strat, litho = voxelstack_z_positive()
        Δz = fill(0.5, length(strat))
        Δz, _, _ = AtlansApi.shift_down(Δz, strat, litho, surface, modelbase)
        @test all(Δz .≈ [0.5, 0.5, 0.5, 0.5, 0.3])
        
        surface = 2.05
        _, strat, litho = voxelstack_z_positive()
        Δz = fill(0.5, length(strat))
        Δz, _, _ = AtlansApi.shift_down(Δz, strat, litho, surface, modelbase)
        @test all(Δz .≈ [0.5, 0.5, 0.5, 0.55])
    end

    @testset "shift_up" begin
        # Test columns with negative depth values
        modelbase = -2.5
        
        surface = 0.3
        _, strat, litho = voxelstack_z_negative()
        Δz = fill(0.5, length(strat))

        Δz, strat, litho = AtlansApi.shift_up(Δz, strat, litho, surface, modelbase)
        @test all(Δz .≈ [0.5, 0.5, 0.5, 0.5, 0.5, 0.3])
        @test all(strat .== [2, 2, 2, 1, 1, 1])
        @test all(litho .== [3, 2, 1, 3, 2, 2])
        
        surface = 0.05
        _, strat, litho = voxelstack_z_negative()
        Δz = fill(0.5, length(strat))

        Δz, strat, litho = AtlansApi.shift_up(Δz, strat, litho, surface, modelbase)
        @test all(Δz .≈ [0.5, 0.5, 0.5, 0.5, 0.55])
        @test all(strat .== [2, 2, 2, 1, 1])
        @test all(litho .== [3, 2, 1, 3, 2])
        
        # Test columns with positive depth values
        modelbase = 0

        surface = 2.7
        _, strat, litho = voxelstack_z_positive()
        Δz = fill(0.5, length(strat))
        Δz, _, _ = AtlansApi.shift_up(Δz, strat, litho, surface, modelbase)
        @test all(Δz .≈ [0.5, 0.5, 0.5, 0.5, 0.5, 0.2])
        
        surface = 2.54
        _, strat, litho = voxelstack_z_positive()
        Δz = fill(0.5, length(strat))
        Δz, _, _ = AtlansApi.shift_up(Δz, strat, litho, surface, modelbase)
        @test all(Δz .≈ [0.5, 0.5, 0.5, 0.5, 0.54])
    end

    @testset "add_antropogenic" begin
        _, strat, litho = voxelstack_z_negative()
        Δz = fill(0.5, length(strat))

        Δz, strat, litho = AtlansApi.add_antropogenic(Δz, strat, litho, 2.3)
        @test all(Δz .≈ [0.5, 0.5, 0.5, 0.5, 0.5, 2.3])
        @test all(strat .== [2, 2, 2, 1, 1, 1])
        @test all(litho .== [3, 2, 1, 3, 2, 0])
    end

    @testset "prepare_voxelstack" begin
        z, strat, litho = voxelstack_z_positive()

        # Test voxelstack surface is shifted down
        surface = 2.3
        domain = AtlansApi.prepare_voxelstack(z, surface, strat, litho)
        @test isa(domain, Atlans.VerticalDomain)
        @test all(
            domain.z .≈ [
                0.125, 0.375, 0.625, 0.875, 1.125, 1.375, 1.625, 1.875, 2.075, 2.225
            ]
        )
        @test all(
            domain.Δz .≈ [0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.15, 0.15]
        )
        @test all(domain.geology .== [2, 2, 2, 2, 2, 2, 1, 1, 1, 1])
        @test all(domain.lithology .== [3, 3, 2, 2, 1, 1, 3, 3, 2, 2])
        @test all(domain.index .== [1, 1, 2, 2, 3, 3, 4, 4, 5, 5])
        @test domain.n == 10

        # Test voxelstack surface is shifted up
        surface = 2.7
        domain = AtlansApi.prepare_voxelstack(z, surface, strat, litho)
        @test all(
            domain.z .≈ [
                0.125, 0.375, 0.625, 0.875, 1.125, 1.375, 1.625, 1.875, 2.125, 2.375, 2.6
                ]
                )
                @test all(
                    domain.Δz .≈ [0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.2]
                    )
                    @test all(domain.geology .== [2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1])
                    @test all(domain.lithology .== [3, 3, 2, 2, 1, 1, 3, 3, 2, 2, 2])
                    @test all(domain.index .== [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6])
                    @test domain.n == 11
                    
        # Test antropogenic is added to voxelstack            
        surface = 5
        domain = AtlansApi.prepare_voxelstack(z, surface, strat, litho)
        @test all(domain.z .≈ 0.125:0.25:4.875)
        @test all(domain.Δz .≈ 0.25)
        @test all(
            domain.geology .== [2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
        )
        @test all(
            domain.lithology .== [3, 3, 2, 2, 1, 1, 3, 3, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        )
        @test all(
            domain.index .== [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6]
        )
        @test domain.n == 20
    end

    @testset "domainbase" begin
        z, strat, litho = voxelstack_z_positive()
        surface = 2.3
        domain = AtlansApi.prepare_voxelstack(z, surface, strat, litho)
        @test AtlansApi.domainbase(domain) == 0
    end
end