# Filter the eBird data by exotic code

Exotic codes are applied to eBird observations when the species is
believe to be non-native to the given location. This function defines a
filter for the eBird Basic Dataset (EBD) to subset observations to one
or more of the exotic codes: "" (i.e. no code, meaning it is a native
species), "N" (naturalized), "P" (provisional), or "X" (escapee). This
function only defines the filter and, once all filters have been
defined,
[`auk_filter()`](https://cornelllabofornithology.github.io/auk/reference/auk_filter.md)
should be used to call AWK and perform the filtering.

## Usage

``` r
auk_exotic(x, exotic_code, replace = FALSE)
```

## Arguments

- x:

  `auk_ebd` or `auk_sampling` object; reference to file created by
  [`auk_ebd()`](https://cornelllabofornithology.github.io/auk/reference/auk_ebd.md)
  or
  [`auk_sampling()`](https://cornelllabofornithology.github.io/auk/reference/auk_sampling.md).

- exotic_code:

  characterr; exotic codes to filter by. Note that an empty string (""),
  meaning no exotic code, is used for native species.

- replace:

  logical; multiple calls to `auk_exotic()` are additive, unless
  `replace = FALSE`, in which case the previous list of states to filter
  by will be removed and replaced by that in the current call.

## Value

An `auk_ebd` object.

## See also

Other filter:
[`auk_bbox()`](https://cornelllabofornithology.github.io/auk/reference/auk_bbox.md),
[`auk_bcr()`](https://cornelllabofornithology.github.io/auk/reference/auk_bcr.md),
[`auk_breeding()`](https://cornelllabofornithology.github.io/auk/reference/auk_breeding.md),
[`auk_complete()`](https://cornelllabofornithology.github.io/auk/reference/auk_complete.md),
[`auk_country()`](https://cornelllabofornithology.github.io/auk/reference/auk_country.md),
[`auk_county()`](https://cornelllabofornithology.github.io/auk/reference/auk_county.md),
[`auk_date()`](https://cornelllabofornithology.github.io/auk/reference/auk_date.md),
[`auk_distance()`](https://cornelllabofornithology.github.io/auk/reference/auk_distance.md),
[`auk_duration()`](https://cornelllabofornithology.github.io/auk/reference/auk_duration.md),
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
# filter to only native observations
ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
auk_exotic(ebd, exotic_code = "")
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
#>   Exotic Codes: Native
#>   Complete checklists only: no

# filter to native and naturalized observations
auk_exotic(ebd, exotic_code = c("", "N"))
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
#>   Exotic Codes: Native, Naturalized
#>   Complete checklists only: no
```
