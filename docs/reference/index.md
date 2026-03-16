# Package index

## EBD Objects

- [`auk_ebd()`](https://cornelllabofornithology.github.io/auk/reference/auk_ebd.md)
  : Reference to eBird data file
- [`auk_sampling()`](https://cornelllabofornithology.github.io/auk/reference/auk_sampling.md)
  : Reference to eBird sampling event file

## Process Text Files

- [`auk_clean()`](https://cornelllabofornithology.github.io/auk/reference/auk_clean.md)
  : Clean an eBird data file (Deprecated)
- [`auk_select()`](https://cornelllabofornithology.github.io/auk/reference/auk_select.md)
  : Select a subset of columns
- [`auk_split()`](https://cornelllabofornithology.github.io/auk/reference/auk_split.md)
  : Split an eBird data file by species

## Filter

- [`auk_bbox()`](https://cornelllabofornithology.github.io/auk/reference/auk_bbox.md)
  : Filter the eBird data by spatial bounding box
- [`auk_bcr()`](https://cornelllabofornithology.github.io/auk/reference/auk_bcr.md)
  : Filter the eBird data by Bird Conservation Region
- [`auk_breeding()`](https://cornelllabofornithology.github.io/auk/reference/auk_breeding.md)
  : Filter to only include observations with breeding codes
- [`auk_complete()`](https://cornelllabofornithology.github.io/auk/reference/auk_complete.md)
  : Filter out incomplete checklists from the eBird data
- [`auk_country()`](https://cornelllabofornithology.github.io/auk/reference/auk_country.md)
  : Filter the eBird data by country
- [`auk_county()`](https://cornelllabofornithology.github.io/auk/reference/auk_county.md)
  : Filter the eBird data by county
- [`auk_date()`](https://cornelllabofornithology.github.io/auk/reference/auk_date.md)
  : Filter the eBird data by date
- [`auk_distance()`](https://cornelllabofornithology.github.io/auk/reference/auk_distance.md)
  : Filter eBird data by distance travelled
- [`auk_duration()`](https://cornelllabofornithology.github.io/auk/reference/auk_duration.md)
  : Filter the eBird data by duration
- [`auk_exotic()`](https://cornelllabofornithology.github.io/auk/reference/auk_exotic.md)
  : Filter the eBird data by exotic code
- [`auk_extent()`](https://cornelllabofornithology.github.io/auk/reference/auk_extent.md)
  : Filter the eBird data by spatial extent
- [`auk_filter()`](https://cornelllabofornithology.github.io/auk/reference/auk_filter.md)
  : Filter the eBird file using AWK
- [`auk_last_edited()`](https://cornelllabofornithology.github.io/auk/reference/auk_last_edited.md)
  : Filter the eBird data by last edited date
- [`auk_observer()`](https://cornelllabofornithology.github.io/auk/reference/auk_observer.md)
  : Filter the eBird data by observer
- [`auk_project()`](https://cornelllabofornithology.github.io/auk/reference/auk_project.md)
  : Filter the eBird data by project code
- [`auk_protocol()`](https://cornelllabofornithology.github.io/auk/reference/auk_protocol.md)
  : Filter the eBird data by protocol
- [`auk_species()`](https://cornelllabofornithology.github.io/auk/reference/auk_species.md)
  : Filter the eBird data by species
- [`auk_state()`](https://cornelllabofornithology.github.io/auk/reference/auk_state.md)
  : Filter the eBird data by state
- [`auk_time()`](https://cornelllabofornithology.github.io/auk/reference/auk_time.md)
  : Filter the eBird data by checklist start time
- [`auk_year()`](https://cornelllabofornithology.github.io/auk/reference/auk_year.md)
  : Filter the eBird data to a set of years

## Pre-process

- [`auk_rollup()`](https://cornelllabofornithology.github.io/auk/reference/auk_rollup.md)
  : Roll up eBird taxonomy to species
- [`auk_unique()`](https://cornelllabofornithology.github.io/auk/reference/auk_unique.md)
  : Remove duplicate group checklists

## Import

- [`auk_zerofill()`](https://cornelllabofornithology.github.io/auk/reference/auk_zerofill.md)
  [`collapse_zerofill()`](https://cornelllabofornithology.github.io/auk/reference/auk_zerofill.md)
  : Read and zero-fill an eBird data file
- [`read_ebd()`](https://cornelllabofornithology.github.io/auk/reference/read_ebd.md)
  [`read_sampling()`](https://cornelllabofornithology.github.io/auk/reference/read_ebd.md)
  : Read an EBD file

## Modeling

- [`filter_repeat_visits()`](https://cornelllabofornithology.github.io/auk/reference/filter_repeat_visits.md)
  : Filter observations to repeat visits for hierarchical modeling

- [`format_unmarked_occu()`](https://cornelllabofornithology.github.io/auk/reference/format_unmarked_occu.md)
  :

  Format EBD data for occupancy modeling with `unmarked`

## Data

- [`bcr_codes`](https://cornelllabofornithology.github.io/auk/reference/bcr_codes.md)
  : BCR Codes
- [`ebird_states`](https://cornelllabofornithology.github.io/auk/reference/ebird_states.md)
  : eBird States
- [`ebird_taxonomy`](https://cornelllabofornithology.github.io/auk/reference/ebird_taxonomy.md)
  : eBird Taxonomy
- [`valid_protocols`](https://cornelllabofornithology.github.io/auk/reference/valid_protocols.md)
  : Valid Protocols

## Path Management

- [`auk_get_awk_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_get_awk_path.md)
  : OS specific path to AWK executable
- [`auk_get_ebd_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_get_ebd_path.md)
  : Return EBD data path
- [`auk_set_awk_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_set_awk_path.md)
  : Set a custom path to AWK executable
- [`auk_set_ebd_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_set_ebd_path.md)
  : Set the path to EBD text files

## Helpers

- [`auk_ebd_version()`](https://cornelllabofornithology.github.io/auk/reference/auk_ebd_version.md)
  : Get the EBD version and associated taxonomy version
- [`auk_version()`](https://cornelllabofornithology.github.io/auk/reference/auk_version.md)
  : Versions of auk, the EBD, and the eBird taxonomy
- [`ebird_species()`](https://cornelllabofornithology.github.io/auk/reference/ebird_species.md)
  : Lookup species in eBird taxonomy
- [`get_ebird_taxonomy()`](https://cornelllabofornithology.github.io/auk/reference/get_ebird_taxonomy.md)
  : Get eBird taxonomy via the eBird API
- [`process_barcharts()`](https://cornelllabofornithology.github.io/auk/reference/process_barcharts.md)
  : Process eBird bar chart data
