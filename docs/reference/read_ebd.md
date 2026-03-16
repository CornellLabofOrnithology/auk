# Read an EBD file

Read an eBird Basic Dataset file using
[`readr::read_delim()`](https://readr.tidyverse.org/reference/read_delim.html).
`read_ebd()` reads the EBD itself, while read_sampling()\` reads a
sampling event data file.

## Usage

``` r
read_ebd(x, sep = "\t", unique = TRUE, rollup = TRUE)

# S3 method for class 'character'
read_ebd(x, sep = "\t", unique = TRUE, rollup = TRUE)

# S3 method for class 'auk_ebd'
read_ebd(x, sep = "\t", unique = TRUE, rollup = TRUE)

read_sampling(x, sep = "\t", unique = TRUE)

# S3 method for class 'character'
read_sampling(x, sep = "\t", unique = TRUE)

# S3 method for class 'auk_ebd'
read_sampling(x, sep = "\t", unique = TRUE)

# S3 method for class 'auk_sampling'
read_sampling(x, sep = "\t", unique = TRUE)
```

## Arguments

- x:

  filename or `auk_ebd` object with associated output files as created
  by
  [`auk_filter()`](https://cornelllabofornithology.github.io/auk/reference/auk_filter.md).

- sep:

  character; single character used to separate fields within a row.

- unique:

  logical; should duplicate grouped checklists be removed. If
  `unique = TRUE`,
  [`auk_unique()`](https://cornelllabofornithology.github.io/auk/reference/auk_unique.md)
  is called on the EBD before returning.

- rollup:

  logical; should taxonomic rollup to species level be applied. If
  `rollup = TRUE`,
  [`auk_rollup()`](https://cornelllabofornithology.github.io/auk/reference/auk_rollup.md)
  is called on the EBD before returning. Note that this process can be
  time consuming for large files, try turning rollup off if reading is
  taking too long.

## Value

A data frame of EBD observations. An additional column, `checklist_id`,
is added to output files if `unique = TRUE`, that uniquely identifies
the checklist from which the observation came. This field is equal to
`sampling_event_identifier` for non-group checklists, and
`group_identifier` for group checklists.

## Details

This functions performs the following processing steps:

- Data types for columns are manually set based on column names used in
  the February 2017 EBD. If variables are added or names are changed in
  later releases, any new variables will have data types inferred by the
  import function used.

- Variables names are converted to `snake_case`.

- Duplicate observations resulting from group checklists are removed
  using
  [`auk_unique()`](https://cornelllabofornithology.github.io/auk/reference/auk_unique.md),
  unless `unique = FALSE`.

## Methods (by class)

- `read_ebd(character)`: Filename of EBD.

- `read_ebd(auk_ebd)`: `auk_ebd` object output from
  [`auk_filter()`](https://cornelllabofornithology.github.io/auk/reference/auk_filter.md)

## Functions

- `read_sampling(character)`: Filename of sampling event data file

- `read_sampling(auk_ebd)`: `auk_ebd` object output from
  [`auk_filter()`](https://cornelllabofornithology.github.io/auk/reference/auk_filter.md).
  Must have had a sampling event data file set in the original call to
  [`auk_ebd()`](https://cornelllabofornithology.github.io/auk/reference/auk_ebd.md).

- `read_sampling(auk_sampling)`: `auk_sampling` object output from
  [`auk_filter()`](https://cornelllabofornithology.github.io/auk/reference/auk_filter.md).

## See also

Other import:
[`auk_zerofill()`](https://cornelllabofornithology.github.io/auk/reference/auk_zerofill.md)

## Examples

``` r
f <- system.file("extdata/ebd-sample.txt", package = "auk")
read_ebd(f)
#> # A tibble: 392 × 51
#>    checklist_id global_unique_identi…¹ last_edited_date taxonomic_order category
#>    <chr>        <chr>                  <chr>                      <dbl> <chr>   
#>  1 G1158137     URN:CornellLabOfOrnit… 2025-10-09 04:1…           21181 species 
#>  2 G1248339     URN:CornellLabOfOrnit… 2023-10-24 20:2…           21233 species 
#>  3 G1277458     URN:CornellLabOfOrnit… 2025-10-20 12:2…           21233 species 
#>  4 G1277459     URN:CornellLabOfOrnit… 2021-06-19 16:1…           21233 species 
#>  5 G1277523     URN:CornellLabOfOrnit… 2025-10-20 12:1…           21233 species 
#>  6 G1351311     URN:CornellLabOfOrnit… 2022-07-29 00:5…           21181 species 
#>  7 G138493      URN:CornellLabOfOrnit… 2023-11-30 12:3…           21233 species 
#>  8 G1402887     URN:CornellLabOfOrnit… 2020-07-05 14:1…           21233 species 
#>  9 G143641      URN:CornellLabOfOrnit… 2021-04-01 18:2…           21233 species 
#> 10 G144144      URN:CornellLabOfOrnit… 2019-03-29 15:0…           21181 species 
#> # ℹ 382 more rows
#> # ℹ abbreviated name: ¹​global_unique_identifier
#> # ℹ 46 more variables: taxon_concept_id <chr>, common_name <chr>,
#> #   scientific_name <chr>, exotic_code <chr>, observation_count <chr>,
#> #   breeding_code <chr>, breeding_category <chr>, behavior_code <chr>,
#> #   age_sex <chr>, country <chr>, country_code <chr>, state <chr>,
#> #   state_code <chr>, county <chr>, county_code <chr>, iba_code <chr>, …
# read a sampling event data file
x <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") |>
  read_sampling()
```
