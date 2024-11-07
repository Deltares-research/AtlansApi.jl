const SAMPLE_PAYLOAD = JSON3.write(
    Dict(
        "gw" => -1,
        "geojson" => Dict(
            "type" => "FeatureCollection",
            "features" => [
                Dict(
                    "id" => "0",
                    "type" => "Feature",
                    "properties" => Dict("id" => 1, "dikte" => 1.5),
                    "geometry" => Dict(
                        "type" => "Polygon",
                        "coordinates" => [
                            [[137692, 487627], [137787, 487840], [138127, 487910], 
                             [138295, 487791], [138291, 487639], [138156, 487426], 
                             [137860, 487356], [137672, 487451], [137692, 487627]]
                        ]
                    )
                ),
                Dict(
                    "id" => "1",
                    "type" => "Feature",
                    "properties" => Dict("id" => 2, "dikte" => 0.8),
                    "geometry" => Dict(
                        "type" => "Polygon",
                        "coordinates" => [
                            [[139087, 488123], [139411, 487984], [139403, 487762], 
                             [139251, 487697], [139042, 487849], [139087, 488123]]
                        ]
                    )
                ),
                Dict(
                    "id" => "2",
                    "type" => "Feature",
                    "properties" => Dict("id" => 3, "dikte" => 1.2),
                    "geometry" => Dict(
                        "type" => "Polygon",
                        "coordinates" => [
                            [[138623, 486770], [138369, 487106], [138701, 487373], 
                             [139218, 487250], [139255, 486864], [138915, 486905], 
                             [138623, 486770]]
                        ]
                    )
                )
            ],
            "crs" => Dict(
                "type" => "name",
                "properties" => Dict("name" => "urn:ogc:def:crs:EPSG::28992")
            )
        )
    )
)
