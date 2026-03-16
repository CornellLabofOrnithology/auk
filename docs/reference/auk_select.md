# Select a subset of columns

Select a subset of columns from the eBird Basic Dataset (EBD) or the
sampling events file. Subsetting the columns can significantly decrease
file size.

## Usage

``` r
auk_select(x, select, file, sep = "\t", overwrite = FALSE)
```

## Arguments

- x:

  `auk_ebd` or `auk_sampling` object; reference to file created by
  [`auk_ebd()`](https://cornelllabofornithology.github.io/auk/reference/auk_ebd.md)
  or
  [`auk_sampling()`](https://cornelllabofornithology.github.io/auk/reference/auk_sampling.md).

- select:

  character; a character vector specifying the names of the columns to
  select. Columns should be as they appear in the header of the EBD;
  however, names are not case sensitive and spaces may be replaced by
  underscores, e.g. `"COMMON NAME"`, `"common name"`, and
  `"common_NAME"` are all valid.

- file:

  character; output file.

- sep:

  character; the input field separator, the eBird file is tab separated
  by default. Must only be a single character and space delimited is not
  allowed since spaces appear in many of the fields.

- overwrite:

  logical; overwrite output file if it already exists

## Value

Invisibly returns the filename of the output file.

## See also

Other text:
[`auk_clean()`](https://cornelllabofornithology.github.io/auk/reference/auk_clean.md),
[`auk_split()`](https://cornelllabofornithology.github.io/auk/reference/auk_split.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# select a minimal set of columns
out_file <- tempfile()
ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
cols <- c("latitude", "longitude",
          "group identifier", "sampling event identifier", 
          "scientific name", "observation count",
          "observer_id")
selected <- auk_select(ebd, select = cols, file = out_file)
str(read_ebd(selected))
} # }
```
