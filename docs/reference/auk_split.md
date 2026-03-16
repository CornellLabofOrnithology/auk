# Split an eBird data file by species

Given an eBird Basic Dataset (EBD) and a list of species, split the file
into multiple text files, one for each species. This function is
typically used after
[`auk_filter()`](https://cornelllabofornithology.github.io/auk/reference/auk_filter.md)
has been applied if the resulting file is too large to be read in all at
once.

## Usage

``` r
auk_split(
  file,
  species,
  prefix,
  taxonomy_version,
  sep = "\t",
  overwrite = FALSE
)
```

## Arguments

- file:

  character; input file.

- species:

  character; species to filter and split by, provided as scientific or
  English common names, or a mixture of both. These names must match the
  official eBird Taxomony
  ([ebird_taxonomy](https://cornelllabofornithology.github.io/auk/reference/ebird_taxonomy.md)).

- prefix:

  character; a file and directory prefix. For example, if splitting by
  species "A" and "B" and `prefix = "data/ebd_"`, the resulting files
  will be "data/ebd_A.txt" and "data/ebd_B.txt".

- taxonomy_version:

  integer; the version (i.e. year) of the taxonomy. In most cases, this
  should be left empty to use the version of the taxonomy included in
  the package. See
  [`get_ebird_taxonomy()`](https://cornelllabofornithology.github.io/auk/reference/get_ebird_taxonomy.md).

- sep:

  character; the input field separator, the eBird file is tab separated
  by default. Must only be a single character and space delimited is not
  allowed since spaces appear in many of the fields.

- overwrite:

  logical; overwrite output files if they already exists.

## Value

A vector of output filenames, one for each species.

## Details

The list of species is checked against the eBird taxonomy for validity.
This taxonomy is updated once a year in August. The `auk` package
includes a copy of the eBird taxonomy, current at the time of release;
however, if the EBD and `auk` versions are not aligned, you may need to
explicitly specify which version of the taxonomy to use, in which case
the eBird API will be queried to get the correct version of the
taxonomy.

## See also

Other text:
[`auk_clean()`](https://cornelllabofornithology.github.io/auk/reference/auk_clean.md),
[`auk_select()`](https://cornelllabofornithology.github.io/auk/reference/auk_select.md)

## Examples

``` r
if (FALSE) { # \dontrun{
species <- c("Canada Jay", "Cyanocitta stelleri")
# get the path to the example data included in the package
# in practice, provide path to a filtered ebd file
# e.g. f <- "data/ebd_filtered.txt
f <- system.file("extdata/ebd-sample.txt", package = "auk")
# output to a temporary directory for example
# in practice, provide the path to the output location
# e.g. prefix <- "output/ebd_"
prefix <- file.path(tempdir(), "ebd_")
species_files <- auk_split(f, species = species, prefix = prefix)
} # }
```
