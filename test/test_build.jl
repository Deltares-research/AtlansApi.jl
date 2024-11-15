@testset "build" begin
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
end