# Get the EBD version and associated taxonomy version

Based on the filename of eBird Basic Dataset (EBD) or sampling event
data, determine the version (i.e. release date) of this EBD. Also
determine the corresponding taxonomy version. The eBird taxonomy is
updated annually in August.

## Usage

``` r
auk_ebd_version(x, check_exists = TRUE)
```

## Arguments

- x:

  filename of EBD of sampling event data file, `auk_ebd` object, or
  `auk_sampling` object.

- check_exists:

  logical; should the file be checked for existence before processing.
  If `check_exists = TRUE` and the file does not exists, the function
  will raise an error.

## Value

A list with two elements:

- `ebd_version`: a date object specifying the release date of the EBD.

- `taxonomy_version`: the year of the taxonomy used in this EBD.

Both elements will be NA if an EBD version cannot be extracted from the
filename.

## See also

Other helpers:
[`auk_version()`](https://cornelllabofornithology.github.io/auk/reference/auk_version.md),
[`ebird_species()`](https://cornelllabofornithology.github.io/auk/reference/ebird_species.md),
[`get_ebird_taxonomy()`](https://cornelllabofornithology.github.io/auk/reference/get_ebird_taxonomy.md),
[`process_barcharts()`](https://cornelllabofornithology.github.io/auk/reference/process_barcharts.md)

## Examples

``` r
auk_ebd_version("ebd_relAug-2018.txt", check_exists = FALSE)
#> $ebd_version
#> [1] "2018-08-01"
#> 
#> $taxonomy_version
#> [1] 2018
#> 
```
