# Remove duplicate group checklists

eBird checklists can be shared among a group of multiple observers, in
which case observations will be duplicated in the database. This
functions removes these duplicates from the eBird Basic Dataset (EBD) or
the EBD sampling event data (with `checklists_only = TRUE`), creating a
set of unique bird observations. This function is called automatically
by
[`read_ebd()`](https://cornelllabofornithology.github.io/auk/reference/read_ebd.md)
and
[`read_sampling()`](https://cornelllabofornithology.github.io/auk/reference/read_ebd.md).

## Usage

``` r
auk_unique(
  x,
  group_id = "group_identifier",
  checklist_id = "sampling_event_identifier",
  species_id = "scientific_name",
  observer_id = "observer_id",
  checklists_only = FALSE
)
```

## Arguments

- x:

  data.frame; the EBD data frame, typically as imported by
  [`read_ebd()`](https://cornelllabofornithology.github.io/auk/reference/read_ebd.md).

- group_id:

  character; the name of the group ID column.

- checklist_id:

  character; the name of the checklist ID column, each checklist within
  a group will get a unique value for this field. The record with the
  lowest `checklist_id` will be picked as the unique record within each
  group. In the output dataset, this field will be updated to have a
  full list of the checklist IDs that went into this group checklist.

- species_id:

  character; the name of the column identifying species uniquely. This
  is required to ensure that removing duplicates is done independently
  for each species. Note that this will not treat sub-species
  independently and, if that behavior is desired, the user will have to
  generate a column uniquely identifying species and subspecies and pass
  that column's name to this argument.

- observer_id:

  character; the name of the column identifying the owner of this
  instance of the group checklist. In the output dataset, the full list
  of observer IDs will be stored (comma separated) in the new
  `observer_id` field. The order of these IDs will match the order of
  the comma separated checklist IDs.

- checklists_only:

  logical; whether the dataset provided only contains checklist
  information as with the sampling event data file. If this argument is
  `TRUE`, then the `species_id` argument is ignored and removing of
  duplicated records is done at the checklist level not the species
  level.

## Value

A data frame with unique observations, and an additional field,
`checklist_id`, which is a combination of the sampling event and group
IDs.

## Details

This function chooses the checklist within in each that has the lowest
value for the field specified by `checklist_id`. A new column is also
created, `checklist_id`, whose value is the taken from the field
specified in the `checklist_id` parameter for non-group checklists and
from the field specified by the `group_id` parameter for grouped
checklists.

All the checklist and observer IDs for the checklists that comprise a
given group checklist will be retained as a comma separated string
ordered by checklist ID.

## See also

Other pre:
[`auk_rollup()`](https://cornelllabofornithology.github.io/auk/reference/auk_rollup.md)

## Examples

``` r
# read in an ebd file and don't automatically remove duplicates
f <- system.file("extdata/ebd-sample.txt", package = "auk")
ebd <- read_ebd(f, unique = FALSE)
# remove duplicates
ebd_unique <- auk_unique(ebd)
nrow(ebd)
#> [1] 400
nrow(ebd_unique)
#> [1] 392
```
