# Changelog

## auk 0.9.1

CRAN release: 2026-01-13

- ensure taxon_concept_id behaves correctly in auk_rollup() (issue
  [\#94](https://github.com/CornellLabofOrnithology/auk/issues/94))
- update EBD example files to get latest format (e.g. add
  taxon_concept_id)

## auk 0.9.0

CRAN release: 2025-12-17

- update to align with the 2025 taxonomy update

## auk 0.8.2

CRAN release: 2025-06-20

- handle changes to project names resulting from release of eBird
  Projects

## auk 0.8.1

CRAN release: 2025-05-04

- allow
  [`ebird_species()`](https://cornelllabofornithology.github.io/auk/reference/ebird_species.md)
  to search for species codes in addition to scientific and common names
- handle changes to EBD column names resulting from release of eBird
  Projects (issue
  [\#91](https://github.com/CornellLabofOrnithology/auk/issues/91))

## auk 0.8.0

CRAN release: 2025-01-14

- update for 2024 taxonomy
- added a helper function for processing bar chart data from eBird
  [`process_barcharts()`](https://cornelllabofornithology.github.io/auk/reference/process_barcharts.md)

## auk 0.7.0

CRAN release: 2023-11-14

- update for 2023 eBird taxonomy
- no need to restart after setting AWK and EBD paths
- retain breeding codes in
  [`auk_zerofill()`](https://cornelllabofornithology.github.io/auk/reference/auk_zerofill.md)
- changes to conform with deprecation of `.data$` in tidyselect
  expressions
- changes to package-level documentation in roxygen2
- removed non-ASCII characters from datasets

## auk 0.6.0

CRAN release: 2022-10-29

- update for 2022 eBird taxonomy

## auk 0.5.2

- added an `extinct` column to taxonomy

## auk 0.5.1

CRAN release: 2021-10-27

- drop `data.table` dependency, no longer needed with `readr` speed
  improvements
- fix bug arising from ‘breeding bird atlas code’ being renamed to
  ‘breeding code’ (issue
  [\#58](https://github.com/CornellLabofOrnithology/auk/issues/58))

## auk 0.5.0

CRAN release: 2021-09-16

- update to align with 2021 eBird taxonomy

## auk 0.4.4

CRAN release: 2021-07-21

- updates to align with readr 2.0

## auk 0.4.3

CRAN release: 2020-11-23

- [`get_ebird_taxonomy()`](https://cornelllabofornithology.github.io/auk/reference/get_ebird_taxonomy.md)
  now fails gracefully when eBird API is not accessible, fixing the CRAN
  check errors
  <https://cran.r-project.org/web/checks/check_results_auk.html>

## auk 0.4.2

CRAN release: 2020-10-19

- new
  [`auk_county()`](https://cornelllabofornithology.github.io/auk/reference/auk_county.md)
  filter
- new
  [`auk_year()`](https://cornelllabofornithology.github.io/auk/reference/auk_year.md)
  filter
- Drop taxonomy warnings since there was no taxonomy update this year

## auk 0.4.1

CRAN release: 2020-04-03

- Family common names now included in eBird taxonomy
- [`auk_select()`](https://cornelllabofornithology.github.io/auk/reference/auk_select.md)
  now requires certain columns to be kept
- Better handling of file paths with `prefix` argument in
  [`auk_split()`](https://cornelllabofornithology.github.io/auk/reference/auk_split.md)
- Fixed bug causing undescribed species to be dropped by
  [`auk_rollup()`](https://cornelllabofornithology.github.io/auk/reference/auk_rollup.md)
- Add a `ll_digits` argument to
  [`filter_repeat_visits()`](https://cornelllabofornithology.github.io/auk/reference/filter_repeat_visits.md)
  to round lat/lng prior to identifying sites
- Change of default parameters to
  [`filter_repeat_visits()`](https://cornelllabofornithology.github.io/auk/reference/filter_repeat_visits.md)
- [`auk_bbox()`](https://cornelllabofornithology.github.io/auk/reference/auk_bbox.md)
  now takes sf/raster spatial objects and grabs bbox from them

## auk 0.4.0

CRAN release: 2019-09-23

- Updated to 2019 eBird taxonomy
- [`auk_observer()`](https://cornelllabofornithology.github.io/auk/reference/auk_observer.md)
  filter added
- [`tidyr::complete_()`](https://tidyr.tidyverse.org/reference/deprecated-se.html)
  deprecated, stopped using

## auk 0.3.3

CRAN release: 2019-06-23

- Dates can now wrap in
  [`auk_date()`](https://cornelllabofornithology.github.io/auk/reference/auk_date.md),
  e.g. use `date = c("*-12-01", "*-01-31")` for records from December or
  January
- Fixed bug preventing dropping of `age/sex` column
- Allow for a wider variety of protocols in
  [`auk_protocol()`](https://cornelllabofornithology.github.io/auk/reference/auk_protocol.md)
- Addresing some deprecated functions from rlang
- Fixed bug causing
  [`auk_set_awk_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_set_awk_path.md)
  to fail

## auk 0.3.2

CRAN release: 2019-02-04

- Work around for bug in system2() in some R versions:
  <https://bugs.r-project.org/bugzilla/show_bug.cgi?id=17508>
- Adding a filter for PROALAS checklists to
  [`auk_protocol()`](https://cornelllabofornithology.github.io/auk/reference/auk_protocol.md)

## auk 0.3.1

CRAN release: 2018-12-07

- [`rlang::UQ()`](https://rlang.r-lib.org/reference/UQ.html) and
  [`rlang::UQS()`](https://rlang.r-lib.org/reference/UQ.html)
  deprecated, switching to `!!` and `!!!`
- [`auk_unique()`](https://cornelllabofornithology.github.io/auk/reference/auk_unique.md)
  now keeps track of all sampling event and observer IDs that comprise a
  group checklist

## auk 0.3.0

CRAN release: 2018-10-04

- Updated to 2018 taxonomy; new function
  [`get_ebird_taxonomy()`](https://cornelllabofornithology.github.io/auk/reference/get_ebird_taxonomy.md)
  to get taxonomy via the eBird API
- Better handling of taxonomy versions, many functions now take a
  `taxonomy_version` argument and use the eBird API to get the taxonomy
- `auk_getpath()` renamed
  [`auk_get_awk_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_get_awk_path.md),
  and added
  [`auk_set_awk_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_set_awk_path.md)
- Added
  [`auk_set_ebd_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_set_ebd_path.md)
  and
  [`auk_get_ebd_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_get_ebd_path.md)
  to set and get the `EBD_PATH` environment variable. Now users only
  need to set this once and just refer to the file name, rather than
  specifying the full path every time.
- Functions to prepare data for occupancy modeling:
  [`filter_repeat_visits()`](https://cornelllabofornithology.github.io/auk/reference/filter_repeat_visits.md)
  and
  [`format_unmarked_occu()`](https://cornelllabofornithology.github.io/auk/reference/format_unmarked_occu.md)
- New
  [`auk_bcr()`](https://cornelllabofornithology.github.io/auk/reference/auk_bcr.md)
  function to extract data from BCRs
- Added `bcr_codes` data frame to look up BCR names and codes
- “Area” protocol added to
  [`auk_protocol()`](https://cornelllabofornithology.github.io/auk/reference/auk_protocol.md)
  filter.
- [`auk_extent()`](https://cornelllabofornithology.github.io/auk/reference/auk_extent.md)
  renamed
  [`auk_bbox()`](https://cornelllabofornithology.github.io/auk/reference/auk_bbox.md);
  [`auk_extent()`](https://cornelllabofornithology.github.io/auk/reference/auk_extent.md)
  deprecated and redirects to
  [`auk_bbox()`](https://cornelllabofornithology.github.io/auk/reference/auk_bbox.md)
- [`auk_zerofill()`](https://cornelllabofornithology.github.io/auk/reference/auk_zerofill.md)
  now checks for complete checklists and gives option to not rollup
- [`auk_rollup()`](https://cornelllabofornithology.github.io/auk/reference/auk_rollup.md)
  now gives the option of keeping higher taxa via `drop_higher` argument
- [`auk_clean()`](https://cornelllabofornithology.github.io/auk/reference/auk_clean.md)
  deprecated
- Fixed package load error when `EBD_PATH` is invalid
- Fixed bug when reading files with a blank column using `readr`

## auk 0.2.2

CRAN release: 2018-07-23

- Updated to work with EDB version 1.9
- Modified tests to be more general to all sample data
- [`ebird_species()`](https://cornelllabofornithology.github.io/auk/reference/ebird_species.md)
  now returns 6-letter species codes
- Fixed bug causing auk to fail on files downloaded via custom download
  form
- Fixed bug with
  [`normalizePath()`](https://rdrr.io/r/base/normalizePath.html) use on
  Windows
- Fixed bug with [`system2()`](https://rdrr.io/r/base/system2.html) on
  Windows

## auk 0.2.1

CRAN release: 2018-03-28

- Patch release fixing a couple bugs
- Removed all non-ASCII characters from example files, closes
  [issue](https://github.com/CornellLabofOrnithology/auk/issues/14)
  [\#14](https://github.com/CornellLabofOrnithology/auk/issues/14)
- Fixed issue with state filtering not working, closes [issue
  \$16](https://github.com/CornellLabofOrnithology/auk/issues/16)

## auk 0.2.0

CRAN release: 2018-03-20

- New function,
  [`auk_split()`](https://cornelllabofornithology.github.io/auk/reference/auk_split.md),
  splits EBD up into multiple files by species
- New object, `auk_sampling`, and associated methods for working with
  the sampling data only
- New function,
  [`auk_select()`](https://cornelllabofornithology.github.io/auk/reference/auk_select.md),
  for selecting a subset of columns
- [`auk_date()`](https://cornelllabofornithology.github.io/auk/reference/auk_date.md)
  now allows filtering date ranges across years using wildcards,
  e.g. `date = c("*-05-01", "*-06-30")` for observations from May and
  June of any year
- New function,
  [`auk_state()`](https://cornelllabofornithology.github.io/auk/reference/auk_state.md)
  for filtering by state
- Now using AWK arrays to speed up country and species filtering; ~20%
  speed up when filtering on many species/countries
- Allow selection of a subset of columns when filtering
- Remove free text columns in
  [`auk_clean()`](https://cornelllabofornithology.github.io/auk/reference/auk_clean.md)
  to decrease file size
- Updated to work with Feb 2018 version of EBD
- Fixed broken dependency on `countrycode` package

## auk 0.1.0

CRAN release: 2017-10-21

- eBird taxonomy update to August 2017 version, users should download
  the most recent EBD to ensure the taxonomy is in sync with the new
  package
- Manually set AWK path with environment variable `AWK_PATH` in
  `.Renviron` file
- `auk_distance`, `auk_breeding`, `auk_protocol`, and `auk_project`
  filters added
- Users can now specify a subset of columns to return when calling
  auk_filter using the keep and drop arguments
- Many changes suggested by rOpenSci package peer review process, see
  <https://github.com/ropensci/onboarding/issues/136> for details
- New vignette added to aid those wanting to contribute to package
  development

## auk 0.0.2

CRAN release: 2017-07-05

- Patch release converting ebird_taxonomy to ASCII to pass CRAN checks

## auk 0.0.1

CRAN release: 2017-07-05

- First CRAN release
