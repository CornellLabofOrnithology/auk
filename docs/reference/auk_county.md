# Filter the eBird data by county

Define a filter for the eBird Basic Dataset (EBD) based on a set of
counties This function only defines the filter and, once all filters
have been defined,
[`auk_filter()`](https://cornelllabofornithology.github.io/auk/reference/auk_filter.md)
should be used to call AWK and perform the filtering.

## Usage

``` r
auk_county(x, county, replace = FALSE)
```

## Arguments

- x:

  `auk_ebd` or `auk_sampling` object; reference to file created by
  [`auk_ebd()`](https://cornelllabofornithology.github.io/auk/reference/auk_ebd.md)
  or
  [`auk_sampling()`](https://cornelllabofornithology.github.io/auk/reference/auk_sampling.md).

- county:

  character; counties to filter by. eBird uses county codes consisting
  of three parts, the 2-letter ISO country code, a 1-3 character state
  code, and a county code, all separated by a dash. For example,
  `"US-NY-109"` corresponds to Tompkins, NY, US. The easiest way to find
  a county code is to find the corresponding [explore
  region](https://ebird.org/explore) page and look at the URL.

- replace:

  logical; multiple calls to `auk_county()` are additive, unless
  `replace = FALSE`, in which case the previous list of states to filter
  by will be removed and replaced by that in the current call.

## Value

An `auk_ebd` object.

## Details

It is not possible to filter by both county as well as country or state,
so calling `auk_county()` will reset these filters to all countries and
states, and vice versa.

This function can also work with on an `auk_sampling` object if the user
only wishes to filter the sampling event data.

## See also

Other filter:
[`auk_bbox()`](https://cornelllabofornithology.github.io/auk/reference/auk_bbox.md),
[`auk_bcr()`](https://cornelllabofornithology.github.io/auk/reference/auk_bcr.md),
[`auk_breeding()`](https://cornelllabofornithology.github.io/auk/reference/auk_breeding.md),
[`auk_complete()`](https://cornelllabofornithology.github.io/auk/reference/auk_complete.md),
[`auk_country()`](https://cornelllabofornithology.github.io/auk/reference/auk_country.md),
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
# choose tompkins county, ny, united states
system.file("extdata/ebd-sample.txt", package = "auk") |>
  auk_ebd() |>
  auk_county("US-NY-109")
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
#>   Counties: US-NY-109
#>   BCRs: all
#>   Bounding box: full extent
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
auk_county(ebd, "US-NY-109")
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
#>   Counties: US-NY-109
#>   BCRs: all
#>   Bounding box: full extent
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
