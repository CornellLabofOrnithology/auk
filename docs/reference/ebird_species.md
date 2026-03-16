# Lookup species in eBird taxonomy

Given a list of common or scientific names, or species codes, check that
they appear in the official eBird taxonomy and convert them all to
scientific names, common names, or species codes. Un-matched species are
returned as `NA`.

## Usage

``` r
ebird_species(
  x,
  type = c("scientific", "common", "code", "all"),
  taxonomy_version
)
```

## Arguments

- x:

  character; species to look up, provided as scientific names, English
  common names, species codes, or a mixture of all three. Case
  insensitive.

- type:

  character; whether to return scientific names (`scientific`), English
  common names (`common`), or 6-letter eBird species codes (`code`).
  Alternatively, use `all` to return a data frame with the all the
  taxonomy information.

- taxonomy_version:

  integer; the version (i.e. year) of the taxonomy. Leave empty to use
  the version of the taxonomy included in the package. See
  [`get_ebird_taxonomy()`](https://cornelllabofornithology.github.io/auk/reference/get_ebird_taxonomy.md).

## Value

Character vector of species identified by scientific name, common name,
or species code. If `type = "all"` a data frame of the taxonomy of the
requested species is returned.

## See also

Other helpers:
[`auk_ebd_version()`](https://cornelllabofornithology.github.io/auk/reference/auk_ebd_version.md),
[`auk_version()`](https://cornelllabofornithology.github.io/auk/reference/auk_version.md),
[`get_ebird_taxonomy()`](https://cornelllabofornithology.github.io/auk/reference/get_ebird_taxonomy.md),
[`process_barcharts()`](https://cornelllabofornithology.github.io/auk/reference/process_barcharts.md)

## Examples

``` r
# mix common and scientific names, case-insensitive
species <- c("Blackburnian Warbler", "Poecile atricapillus",
             "american dipper", "Caribou", "hudgod")
# note that species not in the ebird taxonomy return NA
ebird_species(species)
#> [1] "Setophaga fusca"      "Poecile atricapillus" "Cinclus mexicanus"   
#> [4] NA                     "Limosa haemastica"   

# use taxonomy_version to query older taxonomy versions
if (FALSE) { # \dontrun{
ebird_species("Cordillera Azul Antbird")
ebird_species("Cordillera Azul Antbird", taxonomy_version = 2017)
} # }
```
