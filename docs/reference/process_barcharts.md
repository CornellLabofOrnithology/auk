# Process eBird bar chart data

eBird bar charts show the frequency of detection for each week for all
species within a region. These can be accessed by visiting any region or
hotspot page and clicking the "Bar Charts" link in the left column. As
an example, these [bar charts for
Guatemala](https://ebird.org/barchart?r=GT&yr=all&m=) list all the
species (as well as non-species taxa) that have been observed in eBird
in Guatemala and, for each species, the width of the green bar reflects
the frequency of detections on eBird checklists within the region
(referred to as detection frequency). Detection frequency is provide for
each of 4 "weeks" of each month (although these are not technically 7
day weeks since months have more than 28 days). The data underlying the
bar charts can be downloaded via a link at the bottom right of the page;
however, the text file that's downloaded is in a challenging format to
work with. This function is designed to read these text files and return
a nicely formatted data frame for use in R.

## Usage

``` r
process_barcharts(filename)
```

## Arguments

- filename:

  character; path to the bar chart data text file downloaded from the
  eBird website.

## Value

This functions returns a data frame in long format where each row
provides data for one species in one week. `detection_frequency` gives
the proportion of checklists in the region that reported the species in
the given week and `n_detections` gives the number of detections. The
total number of checklists in each week used to estimate detection
frequency is provided as a data frame stored in the `sample_sizes`
attribute. Note that since most months have more than 28 days, the first
three weeks have 7 days, but the final week has between 7-10 days.

## See also

Other helpers:
[`auk_ebd_version()`](https://cornelllabofornithology.github.io/auk/reference/auk_ebd_version.md),
[`auk_version()`](https://cornelllabofornithology.github.io/auk/reference/auk_version.md),
[`ebird_species()`](https://cornelllabofornithology.github.io/auk/reference/ebird_species.md),
[`get_ebird_taxonomy()`](https://cornelllabofornithology.github.io/auk/reference/get_ebird_taxonomy.md)

## Examples

``` r
# example bar chart data for svalbard
f <- system.file("extdata/barchart-sample.txt", package = "auk")
# import and process barchart data
barcharts <- process_barcharts(f)
head(barcharts)
#> # A tibble: 6 × 8
#>   species_code common_name      scientific_name category month  week
#>   <chr>        <chr>            <chr>           <chr>    <chr> <int>
#> 1 bahgoo       Bar-headed Goose Anser indicus   species  jan       1
#> 2 bahgoo       Bar-headed Goose Anser indicus   species  jan       2
#> 3 bahgoo       Bar-headed Goose Anser indicus   species  jan       3
#> 4 bahgoo       Bar-headed Goose Anser indicus   species  jan       4
#> 5 bahgoo       Bar-headed Goose Anser indicus   species  feb       1
#> 6 bahgoo       Bar-headed Goose Anser indicus   species  feb       2
#> # ℹ 2 more variables: detection_frequency <dbl>, n_detections <dbl>

# the sample sizes for each week can be access with
attr(barcharts, "sample_sizes")
#> # A tibble: 48 × 3
#>    month  week n_checklists
#>    <chr> <int>        <int>
#>  1 jan       1            0
#>  2 jan       2            0
#>  3 jan       3            2
#>  4 jan       4           17
#>  5 feb       1           12
#>  6 feb       2            3
#>  7 feb       3            6
#>  8 feb       4            3
#>  9 mar       1            3
#> 10 mar       2            3
#> # ℹ 38 more rows

# bar charts include data for non-species taxa
# use category to filter to only species
barcharts[barcharts$category == "species", ]
#> # A tibble: 5,376 × 8
#>    species_code common_name      scientific_name category month  week
#>    <chr>        <chr>            <chr>           <chr>    <chr> <int>
#>  1 bahgoo       Bar-headed Goose Anser indicus   species  jan       1
#>  2 bahgoo       Bar-headed Goose Anser indicus   species  jan       2
#>  3 bahgoo       Bar-headed Goose Anser indicus   species  jan       3
#>  4 bahgoo       Bar-headed Goose Anser indicus   species  jan       4
#>  5 bahgoo       Bar-headed Goose Anser indicus   species  feb       1
#>  6 bahgoo       Bar-headed Goose Anser indicus   species  feb       2
#>  7 bahgoo       Bar-headed Goose Anser indicus   species  feb       3
#>  8 bahgoo       Bar-headed Goose Anser indicus   species  feb       4
#>  9 bahgoo       Bar-headed Goose Anser indicus   species  mar       1
#> 10 bahgoo       Bar-headed Goose Anser indicus   species  mar       2
#> # ℹ 5,366 more rows
#> # ℹ 2 more variables: detection_frequency <dbl>, n_detections <dbl>
```
