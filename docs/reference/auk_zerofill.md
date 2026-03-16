# Read and zero-fill an eBird data file

Read an eBird Basic Dataset (EBD) file, and associated sampling event
data file, to produce a zero-filled, presence-absence dataset. The EBD
contains bird sightings and the sampling event data is a set of all
checklists, they can be combined to infer absence data by assuming any
species not reported on a checklist was had a count of zero.

## Usage

``` r
auk_zerofill(x, ...)

# S3 method for class 'data.frame'
auk_zerofill(
  x,
  sampling_events,
  species,
  taxonomy_version,
  collapse = FALSE,
  unique = TRUE,
  rollup = TRUE,
  drop_higher = TRUE,
  complete = TRUE,
  ...
)

# S3 method for class 'character'
auk_zerofill(
  x,
  sampling_events,
  species,
  taxonomy_version,
  collapse = FALSE,
  unique = TRUE,
  rollup = TRUE,
  drop_higher = TRUE,
  complete = TRUE,
  sep = "\t",
  ...
)

# S3 method for class 'auk_ebd'
auk_zerofill(
  x,
  species,
  taxonomy_version,
  collapse = FALSE,
  unique = TRUE,
  rollup = TRUE,
  drop_higher = TRUE,
  complete = TRUE,
  sep = "\t",
  ...
)

collapse_zerofill(x)
```

## Arguments

- x:

  filename, `data.frame` of eBird observations, or `auk_ebd` object with
  associated output files as created by
  [`auk_filter()`](https://cornelllabofornithology.github.io/auk/reference/auk_filter.md).
  If a filename is provided, it must point to the EBD and the
  `sampling_events` argument must point to the sampling event data file.
  If a `data.frame` is provided it should have been imported with
  [`read_ebd()`](https://cornelllabofornithology.github.io/auk/reference/read_ebd.md),
  to ensure the variables names have been set correctly, and it must
  have been passed through
  [`auk_unique()`](https://cornelllabofornithology.github.io/auk/reference/auk_unique.md)
  to ensure duplicate group checklists have been removed.

- ...:

  additional arguments passed to methods.

- sampling_events:

  character or `data.frame`; filename for the sampling event data or a
  `data.frame` of the same data. If a `data.frame` is provided it should
  have been imported with
  [`read_sampling()`](https://cornelllabofornithology.github.io/auk/reference/read_ebd.md),
  to ensure the variables names have been set correctly, and it must
  have been passed through
  [`auk_unique()`](https://cornelllabofornithology.github.io/auk/reference/auk_unique.md)
  to ensure duplicate group checklists have been removed.

- species:

  character; species to include in zero-filled dataset, provided as
  scientific or English common names, or a mixture of both. These names
  must match the official eBird Taxomony
  ([ebird_taxonomy](https://cornelllabofornithology.github.io/auk/reference/ebird_taxonomy.md)).
  To include all species, leave this argument blank.

- taxonomy_version:

  integer; the version (i.e. year) of the taxonomy. In most cases, this
  should be left empty to use the version of the taxonomy included in
  the package. See
  [`get_ebird_taxonomy()`](https://cornelllabofornithology.github.io/auk/reference/get_ebird_taxonomy.md).

- collapse:

  logical; whether to call `collapse_zerofill()` to return a data frame
  rather than an `auk_zerofill` object.

- unique:

  logical; should
  [`auk_unique()`](https://cornelllabofornithology.github.io/auk/reference/auk_unique.md)
  be run on the input data if it hasn't already.

- rollup:

  logical; should
  [`auk_rollup()`](https://cornelllabofornithology.github.io/auk/reference/auk_rollup.md)
  be run on the input data if it hasn't already.

- drop_higher:

  logical; whether to remove taxa above species during the rollup
  process, e.g. "spuhs" like "duck sp.". See
  [`auk_rollup()`](https://cornelllabofornithology.github.io/auk/reference/auk_rollup.md).

- complete:

  logical; if `TRUE` (the default) all checklists are required to be
  complete prior to zero-filling.

- sep:

  character; single character used to separate fields within a row.

## Value

By default, an `auk_zerofill` object, or a data frame if
`collapse = TRUE`.

## Details

`auk_zerofill()` generates an `auk_zerofill` object consisting of a list
with elements `observations` and `sampling_events`. `observations` is a
data frame giving counts and binary presence/absence data for each
species. `sampling_events` is a data frame with checklist level
information. The two data frames can be connected via the `checklist_id`
field. This format is efficient for storage since the checklist columns
are not duplicated for each species, however, working with the data
often requires joining the two data frames together.

To return a data frame, set `collapse = TRUE`. Alternatively,
`zerofill_collapse()` generates a data frame from an `auk_zerofill`
object, by joining the two data frames together to produce a single data
frame in which each row provides both checklist and species information
for a sighting.

The list of species is checked against the eBird taxonomy for validity.
This taxonomy is updated once a year in August. The `auk` package
includes a copy of the eBird taxonomy, current at the time of release;
however, if the EBD and `auk` versions are not aligned, you may need to
explicitly specify which version of the taxonomy to use, in which case
the eBird API will be queried to get the correct version of the
taxonomy.

## Methods (by class)

- `auk_zerofill(data.frame)`: EBD data frame.

- `auk_zerofill(character)`: Filename of EBD.

- `auk_zerofill(auk_ebd)`: `auk_ebd` object output from
  [`auk_filter()`](https://cornelllabofornithology.github.io/auk/reference/auk_filter.md).
  Must have had a sampling event data file set in the original call to
  [`auk_ebd()`](https://cornelllabofornithology.github.io/auk/reference/auk_ebd.md).

## See also

Other import:
[`read_ebd()`](https://cornelllabofornithology.github.io/auk/reference/read_ebd.md)

## Examples

``` r
# read and zero-fill the ebd data
f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
auk_zerofill(x = f_ebd, sampling_events = f_smpl)
#> Zero-filled EBD: 706 unique checklists, for 3 species.

# use the species argument to only include a subset of species
auk_zerofill(x = f_ebd, sampling_events = f_smpl,
             species = "Collared Kingfisher")
#> Zero-filled EBD: 706 unique checklists, for 1 species.

# to return a data frame use collapse = TRUE
ebd_df <- auk_zerofill(x = f_ebd, sampling_events = f_smpl, collapse = TRUE)
```
