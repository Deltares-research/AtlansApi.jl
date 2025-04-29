
<a id='API-Reference'></a>

<a id='API-Reference-1'></a>

# API Reference


*This is the private internal documentation of the AtlansApi API.*

- [API Reference](index.md#API-Reference)
    - [Index](index.md#Index)
    - [Specific function](index.md#Specific-function)
    - [Modules](index.md#Modules)
    - [Types](index.md#Types)
    - [Functions](index.md#Functions)
    - [Constants](index.md#Constants)
    - [Macros](index.md#Macros)


<a id='Index'></a>

<a id='Index-1'></a>

## Index

- [`Atlans.Model`](index.md#Atlans.Model-Tuple{AtlansApi.GeoTop, Rasters.Raster, Rasters.Raster, Number})
- [`AtlansApi.GeoTop`](index.md#AtlansApi.GeoTop-Tuple{AbstractString, AtlansApi.BoundingBox})
- [`AtlansApi.GeoTop`](index.md#AtlansApi.GeoTop-Tuple{NCDatasets.NCDataset, AtlansApi.BoundingBox})
- [`AtlansApi.add_antropogenic`](index.md#AtlansApi.add_antropogenic-NTuple{4, Any})
- [`AtlansApi.create_surcharge`](index.md#AtlansApi.create_surcharge-Tuple{Rasters.Raster})
- [`AtlansApi.generate_unique_directory_id`](index.md#AtlansApi.generate_unique_directory_id-Tuple{})
- [`AtlansApi.prepare_voxelstack`](index.md#AtlansApi.prepare_voxelstack-NTuple{4, Any})
- [`AtlansApi.rasterize_like`](index.md#AtlansApi.rasterize_like-Tuple{AtlansApi.Features, AtlansApi.GeoTop, Symbol})
- [`AtlansApi.rasterize_like`](index.md#AtlansApi.rasterize_like-Tuple{AtlansApi.Features, AtlansApi.GeoTop})
- [`AtlansApi.rasterize_like`](index.md#AtlansApi.rasterize_like)
- [`AtlansApi.read_ahn`](index.md#AtlansApi.read_ahn-Tuple{AbstractString, AtlansApi.BoundingBox})
- [`AtlansApi.run`](index.md#AtlansApi.run-Tuple{Atlans.Simulation})
- [`AtlansApi.run_model`](index.md#AtlansApi.run_model-Tuple{HTTP.Messages.Request})
- [`AtlansApi.run_model`](index.md#AtlansApi.run_model-Tuple{AtlansApi.Features, Number})
- [`AtlansApi.session`](index.md#AtlansApi.session-Tuple{String, Int64})
- [`AtlansApi.shift_down`](index.md#AtlansApi.shift_down-NTuple{5, Any})
- [`AtlansApi.shift_up`](index.md#AtlansApi.shift_up-NTuple{5, Any})
- [`AtlansApi.surcharge_netcdf`](index.md#AtlansApi.surcharge_netcdf-Tuple{Rasters.Raster})
- [`Base.write`](index.md#Base.write-Tuple{AtlansApi.SurchargeResult, AbstractString, AbstractString})


<a id='Specific-function'></a>

<a id='Specific-function-1'></a>

## Specific function



<a id='AtlansApi.rasterize_like' href='#AtlansApi.rasterize_like'>#</a>
**`AtlansApi.rasterize_like`** &mdash; *Function*.



```julia
rasterize_like(features::GeoJSON.FeatureCollection, geotop::GeoTop; kw...)
```

Rasterize the "fids" of an incoming geojson with polygons within the 2D raster extent of the modelling area of GeoTop.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/rasterize.jl#L1-L6' class='documenter-source'>source</a><br>


```julia
rasterize_like(features::GeoJSON.FeatureCollection, geotop::GeoTop, field::Symbol)
```

Rasterize a field of an incoming geojson with polygons within the 2D raster extent of the modelling area of GeoTop.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/rasterize.jl#L14-L19' class='documenter-source'>source</a><br>


<a id='Modules'></a>

<a id='Modules-1'></a>

## Modules


<a id='Types'></a>

<a id='Types-1'></a>

## Types

<a id='Atlans.Model-Tuple{AtlansApi.GeoTop, Rasters.Raster, Rasters.Raster, Number}' href='#Atlans.Model-Tuple{AtlansApi.GeoTop, Rasters.Raster, Rasters.Raster, Number}'>#</a>
**`Atlans.Model`** &mdash; *Method*.



```julia
Model(geotop::GeoTop, ahn::Raster, thickness::Raster, gw::Number)
```

Create a model of Atlantis SoilColumns based on the provided geographical and geological data. SoilColumns are created for locations where surcharge thickness is available.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/run.jl#L4-L9' class='documenter-source'>source</a><br>

<a id='AtlansApi.GeoTop-Tuple{AbstractString, AtlansApi.BoundingBox}' href='#AtlansApi.GeoTop-Tuple{AbstractString, AtlansApi.BoundingBox}'>#</a>
**`AtlansApi.GeoTop`** &mdash; *Method*.



```julia
GeoTop(url::AbstractString, bbox::BoundingBox)
```

Read GeoTop data directly from the Opendap server for a selected area in a bounding box.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/io.jl#L4-L8' class='documenter-source'>source</a><br>

<a id='AtlansApi.GeoTop-Tuple{NCDatasets.NCDataset, AtlansApi.BoundingBox}' href='#AtlansApi.GeoTop-Tuple{NCDatasets.NCDataset, AtlansApi.BoundingBox}'>#</a>
**`AtlansApi.GeoTop`** &mdash; *Method*.



```julia
GeoTop(geotop::Dataset, bbox::BoundingBox)
```

Select GeoTop data for a selected bounding box from a NCDatasets.Dataset.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/io.jl#L16-L20' class='documenter-source'>source</a><br>


<a id='Functions'></a>

<a id='Functions-1'></a>

## Functions

<a id='AtlansApi.add_antropogenic-NTuple{4, Any}' href='#AtlansApi.add_antropogenic-NTuple{4, Any}'>#</a>
**`AtlansApi.add_antropogenic`** &mdash; *Method*.



```julia
add_antropogenic(
	thickness::Vector{Number},
	strat::Vector{Number},
	litho::Vector{Number},
	difference::Number
)
```

Add a layer of antropogenic material to the voxelstack with the appropriate thickness.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/build.jl#L149-L158' class='documenter-source'>source</a><br>

<a id='AtlansApi.create_surcharge-Tuple{Rasters.Raster}' href='#AtlansApi.create_surcharge-Tuple{Rasters.Raster}'>#</a>
**`AtlansApi.create_surcharge`** &mdash; *Method*.



```julia
create_surcharge(thickness::Raster)
```

Create an Atlantis `Surcharge` based on the Raster dataset with the surcharge thickness to apply. Returns an `Atlans.Forcings` object that contains the surcharge and which can be passed to an Atlantis model simulation.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/build.jl#L65-L71' class='documenter-source'>source</a><br>

<a id='AtlansApi.generate_unique_directory_id-Tuple{}' href='#AtlansApi.generate_unique_directory_id-Tuple{}'>#</a>
**`AtlansApi.generate_unique_directory_id`** &mdash; *Method*.



```julia
generate_unique_directory_id()
```

Helper function to generate a unique directory id-hash for different API calls to store model output tifs.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/api.jl#L68-L73' class='documenter-source'>source</a><br>

<a id='AtlansApi.prepare_voxelstack-NTuple{4, Any}' href='#AtlansApi.prepare_voxelstack-NTuple{4, Any}'>#</a>
**`AtlansApi.prepare_voxelstack`** &mdash; *Method*.



```julia
prepare_voxelstack(
	z::Vector{Number},
	surface::Number,
	strat::Vector{Number},
	litho::Vector{Number}
)
```

Create an Atlantis `VerticalDomain` from a voxelstack of GeoTOP. This checks the depths against the surface level elevation and corrects voxel thicknesses that are above or below the surface level. If the surface level elevation is more than 2 meters higher than the elevation of the highest voxel, a layer of antropogenic material is added with the appropriate thickness.

**Arguments:**

  * `z`: NAP Depth of each voxel.
  * `surface`: Surface level elevation in NAP.
  * `strat`: Stratigraphic unit of each voxel.
  * `litho`: Lithology of each voxel.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/build.jl#L169-L188' class='documenter-source'>source</a><br>

<a id='AtlansApi.rasterize_like-Tuple{AtlansApi.Features, AtlansApi.GeoTop, Symbol}' href='#AtlansApi.rasterize_like-Tuple{AtlansApi.Features, AtlansApi.GeoTop, Symbol}'>#</a>
**`AtlansApi.rasterize_like`** &mdash; *Method*.



```julia
rasterize_like(features::GeoJSON.FeatureCollection, geotop::GeoTop, field::Symbol)
```

Rasterize a field of an incoming geojson with polygons within the 2D raster extent of the modelling area of GeoTop.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/rasterize.jl#L14-L19' class='documenter-source'>source</a><br>

<a id='AtlansApi.rasterize_like-Tuple{AtlansApi.Features, AtlansApi.GeoTop}' href='#AtlansApi.rasterize_like-Tuple{AtlansApi.Features, AtlansApi.GeoTop}'>#</a>
**`AtlansApi.rasterize_like`** &mdash; *Method*.



```julia
rasterize_like(features::GeoJSON.FeatureCollection, geotop::GeoTop; kw...)
```

Rasterize the "fids" of an incoming geojson with polygons within the 2D raster extent of the modelling area of GeoTop.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/rasterize.jl#L1-L6' class='documenter-source'>source</a><br>

<a id='AtlansApi.read_ahn-Tuple{AbstractString, AtlansApi.BoundingBox}' href='#AtlansApi.read_ahn-Tuple{AbstractString, AtlansApi.BoundingBox}'>#</a>
**`AtlansApi.read_ahn`** &mdash; *Method*.



```julia
read_ahn(path::AbstractString, bbox::BoundingBox)
```

Read a 100x100 meter resolution tif of AHN data.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/io.jl#L48-L52' class='documenter-source'>source</a><br>

<a id='AtlansApi.run-Tuple{Atlans.Simulation}' href='#AtlansApi.run-Tuple{Atlans.Simulation}'>#</a>
**`AtlansApi.run`** &mdash; *Method*.



```julia
run(simulation::Atlans.Simulation)
```

Run the Atlans.Simulation object and return the subsidence results for "initial" and "remaining" periods.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/run.jl#L106-L111' class='documenter-source'>source</a><br>

<a id='AtlansApi.run_model-Tuple{AtlansApi.Features, Number}' href='#AtlansApi.run_model-Tuple{AtlansApi.Features, Number}'>#</a>
**`AtlansApi.run_model`** &mdash; *Method*.



```julia
run_model(features::Features, groundwater::Number)
```

Run a model simulation using the provided features and groundwater level. This builds an Atlantis model directly from GeoTOP data and a local AHN raster. The simulation is run for a time period of 60 years, divided into the first 3 years ("initial") and the remaining 57 years ("remaining") and returns a `SurchargeResult` object.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/run.jl#L72-L79' class='documenter-source'>source</a><br>

<a id='AtlansApi.run_model-Tuple{HTTP.Messages.Request}' href='#AtlansApi.run_model-Tuple{HTTP.Messages.Request}'>#</a>
**`AtlansApi.run_model`** &mdash; *Method*.



```julia
run_model(req::HTTP.Request)
```

Process an HTTP request to run an Atlantis model simulation for surcharge calculations based on the provided input data.

**Request JSON Structure**

  * `gw`: A numerical value representing the groundwater level.
  * `geojson`: A GeoJSON object representing the geographical features.

**Response JSON Structure**

  * `id`: A unique identifier for the generated directory.
  * `initial`: The file path to the initial TIFF file.
  * `remaining`: The file path to the remaining TIFF file.

**Errors**

  * Returns a 400 HTTP response with an error message if the input is invalid.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/api.jl#L1-L18' class='documenter-source'>source</a><br>

<a id='AtlansApi.session-Tuple{String, Int64}' href='#AtlansApi.session-Tuple{String, Int64}'>#</a>
**`AtlansApi.session`** &mdash; *Method*.



```julia
session(host::String, port::Int)
```

Start an HTTP server session to listen for incoming requests to run Atlantis model simulations.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/api.jl#L48-L52' class='documenter-source'>source</a><br>

<a id='AtlansApi.shift_down-NTuple{5, Any}' href='#AtlansApi.shift_down-NTuple{5, Any}'>#</a>
**`AtlansApi.shift_down`** &mdash; *Method*.



```julia
shift_down(
	thickness::Vector{Number},
	strat::Vector{Number},
	litho::Vector{Number},
	surface::Number,
	modelbase::Number
)
```

Shift the top level of a voxelstack down to the surface level. This function reduces the thickness of the top voxel or adds the thickness of the top voxel to the voxel below if the thickness is less than 0.1 meters.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/build.jl#L88-L100' class='documenter-source'>source</a><br>

<a id='AtlansApi.shift_up-NTuple{5, Any}' href='#AtlansApi.shift_up-NTuple{5, Any}'>#</a>
**`AtlansApi.shift_up`** &mdash; *Method*.



```julia
shift_up(
	thickness::Vector{Number},
	strat::Vector{Number},
	litho::Vector{Number},
	surface::Number,
	modelbase::Number
)
```

Shift the top level of a voxelstack up to the surface level. This function increases the thickness of the top voxel or adds a new voxel with the appropriate thickness.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/build.jl#L122-L133' class='documenter-source'>source</a><br>

<a id='AtlansApi.surcharge_netcdf-Tuple{Rasters.Raster}' href='#AtlansApi.surcharge_netcdf-Tuple{Rasters.Raster}'>#</a>
**`AtlansApi.surcharge_netcdf`** &mdash; *Method*.



```julia
surcharge_netcdf(thickness::Raster)
```

Create a temporary NetCDF Dataset for the surcharge to apply in Atlantis based on a Raster dataset of the surcharge thickness.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/build.jl#L34-L39' class='documenter-source'>source</a><br>

<a id='Base.write-Tuple{AtlansApi.SurchargeResult, AbstractString, AbstractString}' href='#Base.write-Tuple{AtlansApi.SurchargeResult, AbstractString, AbstractString}'>#</a>
**`Base.write`** &mdash; *Method*.



```julia
write(
	result::SurchargeResult,
	path_initial::AbstractString,
	path_remaining::AbstractString
)
```

Write the initial and remaining surcharge results to tif files.


<a target='_blank' href='https://github.com/Deltares-research/AtlansApi.jl/blob/5e7bc985b71dffd92402fdd86976ecfa111ae30b/src/io.jl#L67-L75' class='documenter-source'>source</a><br>


<a id='Constants'></a>

<a id='Constants-1'></a>

## Constants


<a id='Macros'></a>

<a id='Macros-1'></a>

## Macros

