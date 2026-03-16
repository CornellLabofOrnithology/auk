# Filter the eBird data by species

Define a filter for the eBird Basic Dataset (EBD) based on species. This
function only defines the filter and, once all filters have been
defined,
[`auk_filter()`](https://cornelllabofornithology.github.io/auk/reference/auk_filter.md)
should be used to call AWK and perform the filtering.

## Usage

``` r
auk_species(x, species, taxonomy_version, replace = FALSE)
```

## Arguments

- x:

  `auk_ebd` object; reference to object created by
  [`auk_ebd()`](https://cornelllabofornithology.github.io/auk/reference/auk_ebd.md).

- species:

  character; species to filter by, provided as scientific or English
  common names, or a mixture of both. These names must match the
  official eBird Taxomony
  ([ebird_taxonomy](https://cornelllabofornithology.github.io/auk/reference/ebird_taxonomy.md)).

- taxonomy_version:

  integer; the version (i.e. year) of the taxonomy. In most cases, this
  should be left empty to use the version of the taxonomy included in
  the package. See
  [`get_ebird_taxonomy()`](https://cornelllabofornithology.github.io/auk/reference/get_ebird_taxonomy.md).

- replace:

  logical; multiple calls to `auk_species()` are additive, unless
  `replace = FALSE`, in which case the previous list of species to
  filter by will be removed and replaced by that in the current call.

## Value

An `auk_ebd` object.

## Details

The list of species is checked against the eBird taxonomy for validity.
This taxonomy is updated once a year in August. The `auk` package
includes a copy of the eBird taxonomy, current at the time of release;
however, if the EBD and `auk` versions are not aligned, you may need to
explicitly specify which version of the taxonomy to use, in which case
the eBird API will be queried to get the correct version of the
taxonomy.

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
[`auk_exotic()`](https://cornelllabofornithology.github.io/auk/reference/auk_exotic.md),
[`auk_extent()`](https://cornelllabofornithology.github.io/auk/reference/auk_extent.md),
[`auk_filter()`](https://cornelllabofornithology.github.io/auk/reference/auk_filter.md),
[`auk_last_edited()`](https://cornelllabofornithology.github.io/auk/reference/auk_last_edited.md),
[`auk_observer()`](https://cornelllabofornithology.github.io/auk/reference/auk_observer.md),
[`auk_project()`](https://cornelllabofornithology.github.io/auk/reference/auk_project.md),
[`auk_protocol()`](https://cornelllabofornithology.github.io/auk/reference/auk_protocol.md),
[`auk_state()`](https://cornelllabofornithology.github.io/auk/reference/auk_state.md),
[`auk_time()`](https://cornelllabofornithology.github.io/auk/reference/auk_time.md),
[`auk_year()`](https://cornelllabofornithology.github.io/auk/reference/auk_year.md)

## Examples

``` r
# common and scientific names can be mixed
species <- c("Canada Jay", "Pluvialis squatarola")
system.file("extdata/ebd-sample.txt", package = "auk") |>
  auk_ebd() |>
  auk_species(species)
#> Input 
#>   EBD: /private/var/folders/wf/957fnnnd127fsdkxc1dtmc2m0000gp/T/RtmppZXGo8/temp_libpath917c7939de6e/auk/extdata/ebd-sample.txt 
#> 
#> Output 
#>   Filters not executed
#> 
#> Filters 
#>   Species: Perisoreus canadensis, Pluvialis squatarola
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
#>   Exotic Codes: all
#>   Complete checklists only: no
  
# alternatively, without pipes
ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
auk_species(ebd, species)
#> Input 
#>   EBD: /private/var/folders/wf/957fnnnd127fsdkxc1dtmc2m0000gp/T/RtmppZXGo8/temp_libpath917c7939de6e/auk/extdata/ebd-sample.txt 
#> 
#> Output 
#>   Filters not executed
#> 
#> Filters 
#>   Species: Perisoreus canadensis, Pluvialis squatarola
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
#>   Exotic Codes: all
#>   Complete checklists only: no
```
