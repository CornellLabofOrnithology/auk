# Get eBird taxonomy via the eBird API

Get the taxonomy used in eBird via the eBird API.

## Usage

``` r
get_ebird_taxonomy(version, locale)
```

## Arguments

- version:

  integer; the version (i.e. year) of the taxonomy. The eBird taxonomy
  is updated once a year in August. Leave this parameter blank to get
  the current taxonomy.

- locale:

  character; the [locale for the common
  names](https://support.ebird.org/support/solutions/articles/48000804865-bird-names-in-ebird),
  defaults to English.

## Value

A data frame of all species in the eBird taxonomy, consisting of the
following columns:

- `scientific_name`: scientific name.

- `common_name`: common name, defaults to English, but different
  languages can be selected using the `locale` parameter.

- `species_code`: a unique alphanumeric code identifying each species.

- `category`: whether the entry is for a species or another
  field-identifiable taxon, such as `spuh`, `slash`, `hybrid`, etc.

- `taxon_order`: numeric value used to sort rows in taxonomic order.

- `order`: the scientific name of the order that the species belongs to.

- `family`: the scientific name of the family that the species belongs
  to.

- `report_as`: for taxa that can be resolved to true species (i.e.
  species, subspecies, and recognizable forms), this field links to the
  corresponding species code. For taxa that can't be resolved, this
  field is `NA`.

## See also

Other helpers:
[`auk_ebd_version()`](https://cornelllabofornithology.github.io/auk/reference/auk_ebd_version.md),
[`auk_version()`](https://cornelllabofornithology.github.io/auk/reference/auk_version.md),
[`ebird_species()`](https://cornelllabofornithology.github.io/auk/reference/ebird_species.md),
[`process_barcharts()`](https://cornelllabofornithology.github.io/auk/reference/process_barcharts.md)

## Examples

``` r
if (FALSE) { # \dontrun{
get_ebird_taxonomy()
} # }
```
