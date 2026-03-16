# Filter the eBird data by spatial bounding box

Define a filter for the eBird Basic Dataset (EBD) based on spatial
bounding box. This function only defines the filter and, once all
filters have been defined,
[`auk_filter()`](https://cornelllabofornithology.github.io/auk/reference/auk_filter.md)
should be used to call AWK and perform the filtering.

## Usage

``` r
auk_bbox(x, bbox)
```

## Arguments

- x:

  `auk_ebd` or `auk_sampling` object; reference to file created by
  [`auk_ebd()`](https://cornelllabofornithology.github.io/auk/reference/auk_ebd.md)
  or
  [`auk_sampling()`](https://cornelllabofornithology.github.io/auk/reference/auk_sampling.md).

- bbox:

  numeric or `sf` or `Raster*` object; spatial bounding box expressed as
  the range of latitudes and longitudes in decimal degrees:
  `c(lng_min, lat_min, lng_max, lat_max)`. Note that longitudes in the
  Western Hemisphere and latitudes sound of the equator should be given
  as negative numbers. Alternatively, a spatial object from either the
  `sf` or `raster` packages can be provided and the bounding box will be
  extracted from this object.

## Value

An `auk_ebd` object.

## Details

This function can also work with on an `auk_sampling` object if the user
only wishes to filter the sampling event data.

## See also

Other filter:
[`auk_bcr()`](https://cornelllabofornithology.github.io/auk/reference/auk_bcr.md),
[`auk_breeding()`](https://cornelllabofornithology.github.io/auk/reference/auk_breeding.md),
[`auk_complete()`](https://cornelllabofornithology.github.io/auk/reference/auk_complete.md),
[`auk_country()`](https://cornelllabofornithology.github.io/auk/reference/auk_country.md),
[`auk_county()`](https://cornelllabofornithology.github.io/auk/reference/auk_county.md),
[`auk_date()`](https://cornelllabofornithology.github.io/auk/reference/auk_date.md),
[`auk_distance()`](https://cornelllabofornithology.github.io/auk/reference/auk_distance.md),
[`auk_duration()`](https://cornelllabofornithology.github.io/auk/reference/auk_duration.md),
[`auk_exotic()`](https://cornelllabofornithology.github.io/auk/reference/auk_exotic.md),
[`auk_extent()`](https://cornelllabofornithology.github.io/auk/reference/auk_extent.md),
[`auk_filter()`](https://cornelllabofornithology.github.io/auk/reference/auk_filter.md),
[`auk_last_edited()`](https://cornelllabofornithology.github.io/auk/reference/auk_last_edited.md),
[`auk_observer()`](https://cornelllabofornithology.github.io/auk/reference/auk_observer.md),
[`auk_project()`](https://cornelllabofornithology.github.io/auk/reference/auk_project.md),
[`auk_protocol()`](https://cornelllabofornithology.github.io/auk/reference/auk_protocol.md),
[`auk_species()`](https://cornelllabofornithology.github.io/auk/reference/auk_species.md),
[`auk_state()`](https://cornelllabofornithology.github.io/auk/reference/auk_state.md),
[`auk_time()`](https://cornelllabofornithology.github.io/auk/reference/auk_time.md),
[`auk_year()`](https://cornelllabofornithology.github.io/auk/reference/auk_year.md)

## Examples

``` r
# fliter to locations roughly in the Pacific Northwest
system.file("extdata/ebd-sample.txt", package = "auk") |>
  auk_ebd() |>
  auk_bbox(bbox = c(-125, 37, -120, 52))
#> Input 
#>   EBD: /private/var/folders/wf/957fnnnd127fsdkxc1dtmc2m0000gp/T/RtmppZXGo8/temp_libpath917c7939de6e/auk/extdata/ebd-sample.txt 
#> 
#> Output 
#>   Filters not executed
#> 
#> Filters 
#>   Species: all
#>   Countries: all
#>   States: all
#>   Counties: all
#>   BCRs: all
#>   Bounding box: Lon -125 - -120; Lat 37 - 52
#>   Years: all
#>   Date: all
#>   Start time: all
#>   Last edited date: all
#>   Protocol: all
#>   Project code: all
#>   Duration: all
#>   Distance travelled: all
#>   Records with breeding codes only: no
#>   Exotic Codes: all
#>   Complete checklists only: no
  
# alternatively, without pipes
ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
auk_bbox(ebd, bbox = c(-125, 37, -120, 52))
#> Input 
#>   EBD: /private/var/folders/wf/957fnnnd127fsdkxc1dtmc2m0000gp/T/RtmppZXGo8/temp_libpath917c7939de6e/auk/extdata/ebd-sample.txt 
#> 
#> Output 
#>   Filters not executed
#> 
#> Filters 
#>   Species: all
#>   Countries: all
#>   States: all
#>   Counties: all
#>   BCRs: all
#>   Bounding box: Lon -125 - -120; Lat 37 - 52
#>   Years: all
#>   Date: all
#>   Start time: all
#>   Last edited date: all
#>   Protocol: all
#>   Project code: all
#>   Duration: all
#>   Distance travelled: all
#>   Records with breeding codes only: no
#>   Exotic Codes: all
#>   Complete checklists only: no
```
