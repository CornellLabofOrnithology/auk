# Filter the eBird file using AWK

Convert the filters defined in an `auk_ebd` object into an AWK script
and run this script to produce a filtered eBird Reference Dataset (ERD).
The initial creation of the `auk_ebd` object should be done with
[`auk_ebd()`](https://cornelllabofornithology.github.io/auk/reference/auk_ebd.md)
and filters can be defined using the various other functions in this
package, e.g.
[`auk_species()`](https://cornelllabofornithology.github.io/auk/reference/auk_species.md)
or
[`auk_country()`](https://cornelllabofornithology.github.io/auk/reference/auk_country.md).
**Note that this function typically takes at least a couple hours to run
on the full dataset**

## Usage

``` r
auk_filter(x, file, ...)

# S3 method for class 'auk_ebd'
auk_filter(
  x,
  file,
  file_sampling,
  keep,
  drop,
  awk_file,
  sep = "\t",
  filter_sampling = TRUE,
  execute = TRUE,
  overwrite = FALSE,
  ...
)

# S3 method for class 'auk_sampling'
auk_filter(
  x,
  file,
  keep,
  drop,
  awk_file,
  sep = "\t",
  execute = TRUE,
  overwrite = FALSE,
  ...
)
```

## Arguments

- x:

  `auk_ebd` or `auk_sampling` object; reference to file created by
  [`auk_ebd()`](https://cornelllabofornithology.github.io/auk/reference/auk_ebd.md)
  or
  [`auk_sampling()`](https://cornelllabofornithology.github.io/auk/reference/auk_sampling.md).

- file:

  character; output file.

- ...:

  arguments passed on to methods.

- file_sampling:

  character; optional output file for sampling data.

- keep:

  character; a character vector specifying the names of the columns to
  keep in the output file. Columns should be as they appear in the
  header of the EBD; however, names are not case sensitive and spaces
  may be replaced by underscores, e.g. `"COMMON NAME"`, `"common name"`,
  and `"common_NAME"` are all valid.

- drop:

  character; a character vector of columns to drop in the same format as
  `keep`. Ignored if `keep` is supplied.

- awk_file:

  character; output file to optionally save the awk script to.

- sep:

  character; the input field separator, the eBird file is tab separated
  by default. Must only be a single character and space delimited is not
  allowed since spaces appear in many of the fields.

- filter_sampling:

  logical; whether the sampling event data should also be filtered.

- execute:

  logical; whether to execute the awk script, or output it to a file for
  manual execution. If this flag is `FALSE`, `awk_file` must be
  provided.

- overwrite:

  logical; overwrite output file if it already exists

## Value

An `auk_ebd` object with the output files set. If `execute = FALSE`,
then the path to the AWK script is returned instead.

## Details

If a sampling file is provided in the
[auk_ebd](https://cornelllabofornithology.github.io/auk/reference/auk_ebd.md)
object, this function will filter both the eBird Basic Dataset and the
sampling data using the same set of filters. This ensures that the files
are in sync, i.e. that they contain data on the same set of checklists.

The AWK script can be saved for future reference by providing an output
filename to `awk_file`. The default behavior of this function is to
generate and run the AWK script, however, by setting `execute = FALSE`
the AWK script will be generated but not run. In this case, `file` is
ignored and `awk_file` must be specified.

Calling this function requires that the command line utility AWK is
installed. Linux and Mac machines should have AWK by default, Windows
users will likely need to install [Cygwin](https://www.cygwin.com).

## Methods (by class)

- `auk_filter(auk_ebd)`: `auk_ebd` object

- `auk_filter(auk_sampling)`: `auk_sampling` object

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
# get the path to the example data included in the package
# in practice, provide path to ebd, e.g. f <- "data/ebd_relFeb-2018.txt"
f <- system.file("extdata/ebd-sample.txt", package = "auk")
# define filters
filters <- auk_ebd(f) |>
  auk_species(species = c("Canada Jay", "Blue Jay")) |>
  auk_country(country = c("US", "Canada")) |>
  auk_bbox(bbox = c(-100, 37, -80, 52)) |>
  auk_date(date = c("2012-01-01", "2012-12-31")) |>
  auk_time(start_time = c("06:00", "09:00")) |>
  auk_duration(duration = c(0, 60)) |>
  auk_complete()
  
# alternatively, without pipes
ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
filters <- auk_species(ebd, species = c("Canada Jay", "Blue Jay"))
filters <- auk_country(filters, country = c("US", "Canada"))
filters <- auk_bbox(filters, bbox = c(-100, 37, -80, 52))
filters <- auk_date(filters, date = c("2012-01-01", "2012-12-31"))
filters <- auk_time(filters, start_time = c("06:00", "09:00"))
filters <- auk_duration(filters, duration = c(0, 60))
filters <- auk_complete(filters)

# apply filters
if (FALSE) { # \dontrun{
# output to a temp file for example
# in practice, provide path to output file
# e.g. f_out <- "output/ebd_filtered.txt"
f_out <- tempfile()
filtered <- auk_filter(filters, file = f_out)
str(read_ebd(filtered))
} # }
```
