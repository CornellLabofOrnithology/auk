# Roll up eBird taxonomy to species

The eBird Basic Dataset (EBD) includes both true species and every other
field-identifiable taxon that could be relevant for birders to report.
This includes taxa not identifiable to a species (e.g. hybrids) and taxa
reported below the species level (e.g. subspecies). This function
produces a list of observations of true species, by removing the former
and rolling the latter up to the species level. In the resulting EBD
data.frame, `category` will be `"species"` for all records and the
subspecies fields will be dropped. By default,
[`read_ebd()`](https://cornelllabofornithology.github.io/auk/reference/read_ebd.md)
calls `ebd_rollup()` when importing an eBird data file.

## Usage

``` r
auk_rollup(x, drop_higher = TRUE)
```

## Arguments

- x:

  data.frame; data frame of eBird data, typically as imported by
  [`read_ebd()`](https://cornelllabofornithology.github.io/auk/reference/read_ebd.md)

- drop_higher:

  logical; whether to remove taxa above species during the rollup
  process, e.g. "spuhs" like "duck sp.".

## Value

A data frame of the eBird data with taxonomic rollup applied.

## Details

When rolling observations up to species level the observed counts are
summed across any taxa that resolve to the same species. However, if any
of these taxa have a count of "X" (i.e. the observer did not enter a
count), then the rolled up record will get an "X" as well. For example,
if an observer saw 3 Myrtle and 2 Audubon's Warblers, this will roll up
to 5 Yellow-rumped Warblers. However, if an "X" was entered for Myrtle,
this would roll up to "X" for Yellow-rumped Warbler.

The eBird taxonomy groups taxa into eight different categories. These
categories, and the way they are treated by `auk_rollup()` are as
follows:

- **Species:** e.g., Mallard. Combined with lower level taxa if present
  on the same checklist.

- **ISSF or Identifiable Sub-specific Group:** Identifiable subspecies
  or group of subspecies, e.g., Mallard (Mexican). Rolled-up to species
  level.

- **Intergrade:** Hybrid between two ISSF (subspecies or subspecies
  groups), e.g., Mallard (Mexican intergrade. Rolled-up to species
  level.

- **Form:** Miscellaneous other taxa, including recently-described
  species yet to be accepted or distinctive forms that are not
  universally accepted (Red-tailed Hawk (Northern), Upland Goose
  (Bar-breasted)). If the checklist contains multiple taxa corresponding
  to the same species, the lower level taxa are rolled up, otherwise
  these records are left as is.

- **Spuh:** Genus or identification at broad level – e.g., duck sp.,
  dabbling duck sp.. Dropped by `auk_rollup()`.

- **Slash:** Identification to Species-pair e.g., American Black
  Duck/Mallard). Dropped by `auk_rollup()`.

- **Hybrid:** Hybrid between two species, e.g., American Black Duck x
  Mallard (hybrid). Dropped by `auk_rollup()`.

- **Domestic:** Distinctly-plumaged domesticated varieties that may be
  free-flying (these do not count on personal lists) e.g., Mallard
  (Domestic type). Dropped by `auk_rollup()`.

The rollup process is based on the eBird taxonomy, which is updated once
a year in August. The `auk` package includes a copy of the eBird
taxonomy, current at the time of release; however, if the EBD and `auk`
versions are not aligned, you may need to explicitly specify which
version of the taxonomy to use, in which case the eBird API will be
queried to get the correct version of the taxonomy.

## References

Consult the [eBird
taxonomy](https://ebird.org/science/use-ebird-data/the-ebird-taxonomy)
page for further details.

## See also

Other pre:
[`auk_unique()`](https://cornelllabofornithology.github.io/auk/reference/auk_unique.md)

## Examples

``` r
# get the path to the example data included in the package
# in practice, provide path to ebd, e.g. f <- "data/ebd_relFeb-2018.txt
f <- system.file("extdata/ebd-rollup-ex.txt", package = "auk")
# read in data without rolling up
ebd <- read_ebd(f, rollup = FALSE)
# rollup
ebd_ru <- auk_rollup(ebd)
# keep higher taxa
ebd_higher <- auk_rollup(ebd, drop_higher = FALSE)

# all taxa not identifiable to species are dropped
unique(ebd$category)
#> [1] "domestic"   "form"       "hybrid"     "slash"      "spuh"      
#> [6] "issf"       "species"    "intergrade"
unique(ebd_ru$category)
#> [1] "species"
unique(ebd_higher$category)
#> [1] "slash"   "spuh"    "hybrid"  "species"

# yellow-rump warbler subspecies rollup
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
# without rollup, there are multiple observations per checklists
ebd |>
  filter(common_name == "Yellow-rumped Warbler") |>
  select(checklist_id, category, common_name, subspecies_common_name, 
         observation_count)
#> # A tibble: 8 × 5
#>   checklist_id category   common_name   subspecies_common_name observation_count
#>   <chr>        <chr>      <chr>         <chr>                  <chr>            
#> 1 S172058033   issf       Yellow-rumpe… Yellow-rumped Warbler… 9                
#> 2 S172058033   issf       Yellow-rumpe… Yellow-rumped Warbler… 6                
#> 3 S172058033   species    Yellow-rumpe… NA                     8                
#> 4 S172058033   intergrade Yellow-rumpe… Yellow-rumped Warbler… 1                
#> 5 S202723163   issf       Yellow-rumpe… Yellow-rumped Warbler… 3                
#> 6 S202723163   issf       Yellow-rumpe… Yellow-rumped Warbler… 1                
#> 7 S202723163   species    Yellow-rumpe… NA                     1                
#> 8 S202723163   intergrade Yellow-rumpe… Yellow-rumped Warbler… 1                
# with rollup, they have been combined
ebd_ru |>
  filter(common_name == "Yellow-rumped Warbler") |>
  select(checklist_id, category, common_name, observation_count)
#> # A tibble: 2 × 4
#>   checklist_id category common_name           observation_count
#>   <chr>        <chr>    <chr>                 <chr>            
#> 1 S172058033   species  Yellow-rumped Warbler 24               
#> 2 S202723163   species  Yellow-rumped Warbler 6                
```
