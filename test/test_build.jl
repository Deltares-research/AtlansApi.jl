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

        sur = AtlansApi.create_surcharge(t)
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

    @testset "GeoTop" begin
        bbox = AtlansApi.BoundingBox(222, 215, 399, 492)
        gtp = AtlansApi.GeoTop(Fixtures.geotop_nc(), bbox)

        @test all(gtp.x .== [250, 350])
        @test all(gtp.y .== [450, 350, 250])
        @test all(gtp.z .== [-1.75, -1.25, -0.75, -0.25])
        @test size(gtp.strat) == (4, 2, 3)
        @test gtp.bbox.xmin == 200
        @test gtp.bbox.ymin == 200
        @test gtp.bbox.xmax == 400
        @test gtp.bbox.ymax == 500
    end

    @testset "read_ahn" begin
        f = Fixtures.simple_features()

        ahn = AtlansApi.read_ahn(Fixtures.ahn_path(), f.bbox)
        
        @test isa(ahn, Raster)
        
        xcoords = lookup(ahn, X)
        ycoords = lookup(ahn, Y)
        @test all(xcoords .== 250:100:450)
        @test all(ycoords .== 550:-100:150)
        @test all(ahn.data .== [0 0.05 -0.05 0 0; 0 0 0 0 0; 0 0 0 -0.02 0.02])
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

        modelbase = 0

        surface = 2.3
        _, strat, litho = voxelstack_z_positive()
        Δz = fill(0.5, length(strat))

        Δz, strat, litho = AtlansApi.shift_down(Δz, strat, litho, surface, modelbase)
        @test all(Δz .≈ [0.5, 0.5, 0.5, 0.5, 0.3])
        @test all(strat .== [2, 2, 2, 1, 1])
        @test all(litho .== [3, 2, 1, 3, 2])
        
        surface = 2.05
        _, strat, litho = voxelstack_z_positive()
        Δz = fill(0.5, length(strat))

        Δz, strat, litho = AtlansApi.shift_down(Δz, strat, litho, surface, modelbase)
        @test all(Δz .≈ [0.5, 0.5, 0.5, 0.55])
        @test all(strat .== [2, 2, 2, 1])
        @test all(litho .== [3, 2, 1, 3])
    end
end