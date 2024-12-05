@testset "rasterize" begin
	@testset "features_to_rings" begin
		f = Fixtures.simple_features()

		rings = AtlansApi.features_to_rings(f)
		@test isa(
			rings, Vector{Shapefile.LinearRing{Shapefile.Point, Nothing, Nothing}},
		)
		@test all(
			rings[1] .== [
				Shapefile.Point(210.0, 570.0)
				Shapefile.Point(380.0, 570.0)
				Shapefile.Point(210.0, 410.0)
				Shapefile.Point(210.0, 570.0)
			],
		)
		@test all(
			rings[2] .== [
				Shapefile.Point(490.0, 390.0)
				Shapefile.Point(490.0, 110.0)
				Shapefile.Point(330.0, 250.0)
				Shapefile.Point(490.0, 390.0)
			],
		)
	end

	@testset "rasterize_like" begin
		f = Fixtures.simple_features()
		gtp = AtlansApi.GeoTop(Fixtures.geotop_nc(), f.bbox)

		result = AtlansApi.rasterize_like(f, gtp, :thickness)
		@test isa(result, Raster)

		xcoords = lookup(result, X)
		ycoords = lookup(result, Y)
		@test all(xcoords .== 250:100:450)
		@test all(ycoords .== 550:-100:150)

		expected_result = [
			1.2 1.2 NaN NaN NaN; 1.2 1.2 0.8 0.8 0.8; NaN NaN 0.8 0.8 0.8
		]
		comparison = result.data .== expected_result # NaN == NaN is false
		@test all(comparison .== [1 1 0 0 0; 1 1 1 1 1; 0 0 1 1 1])
	end
end
