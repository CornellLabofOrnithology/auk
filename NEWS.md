# auk 1.0.0

- update to 2026 eBird taxonomy
- update to v2 of the eBird API and httr2 (PR #97)
- drop magrittr pipe re-export
- clarify in auk_unique() docs that species reported by any member of a
  shared checklist are retained, and that for checklist-level effort fields
  (duration, distance, protocol, completeness) the value from the member
  with the lowest checklist ID is kept when members disagree (issue #99)
- auk_unique() now always adds an effort_disagreement column flagging
  shared checklists whose members disagreed on effort fields (issue #99)
- fix auk_rollup() incorrectly rolling up "domestic"/feral taxa (e.g. feral
  pigeons) into their wild parent species, since they share the same
  scientific_name
- fix auk_rollup() silently stripping the "unique" attribute set by
  auk_unique(), which could cause auk_zerofill(unique = FALSE) to fail with
  a misleading error, or auk_zerofill() to needlessly redo deduplication
- fix auk_ebd() validating the sampling event file's required columns
  against the EBD's header instead of the sampling file's own header,
  silently skipping the check
- fix auk_zerofill() silently dropping taxonomy_version and drop_higher
  when x was a filename or auk_ebd object instead of a data frame
- fix auk_project() matching project codes as a substring instead of an
  exact match, which could incorrectly include checklists from an
  unrelated project whose code happens to contain the requested one
- fix auk_time() not zero-padding some valid start_time formats (e.g.
  "600"), causing them to be compared incorrectly and excluding matching
  checklists
- fix auk_split() not quoting the input file path passed to AWK, which
  broke on paths containing spaces
- rewrite auk_unique()'s grouping logic to avoid a full-table sort and a
  dplyr group_by()/summarize() pass per shared checklist group, roughly
  2-3x faster on data sets with many shared checklists
- rewrite auk_rollup() to skip the expensive group_by()/slice_min() rollup
  logic for checklist x species groups with only a single record (the vast
  majority, since most species aren't reported as multiple subspecies on
  the same checklist), 5-20x+ faster depending on how much actual rollup
  work is needed

# auk 0.9.1

- ensure taxon_concept_id behaves correctly in auk_rollup() (issue #94)
- update EBD example files to get latest format (e.g. add taxon_concept_id)

# auk 0.9.0

- update to align with the 2025 taxonomy update

# auk 0.8.2

- handle changes to project names resulting from release of eBird Projects

# auk 0.8.1

- allow `ebird_species()` to search for species codes in addition to scientific and common names
- handle changes to EBD column names resulting from release of eBird Projects (issue #91)

# auk 0.8.0

- update for 2024 taxonomy
- added a helper function for processing bar chart data from eBird `process_barcharts()`

# auk 0.7.0

- update for 2023 eBird taxonomy
- no need to restart after setting AWK and EBD paths
- retain breeding codes in `auk_zerofill()`
- changes to conform with deprecation of `.data$` in tidyselect expressions
- changes to package-level documentation in roxygen2
- removed non-ASCII characters from datasets

# auk 0.6.0

- update for 2022 eBird taxonomy

# auk 0.5.2

- added an `extinct` column to taxonomy

# auk 0.5.1

- drop `data.table` dependency, no longer needed with `readr` speed improvements
- fix bug arising from 'breeding bird atlas code' being renamed to 'breeding code' (issue #58)

# auk 0.5.0

- update to align with 2021 eBird taxonomy

# auk 0.4.4

- updates to align with readr 2.0

# auk 0.4.3

- `get_ebird_taxonomy()` now fails gracefully when eBird API is not accessible, fixing the CRAN check errors https://cran.r-project.org/web/checks/check_results_auk.html

# auk 0.4.2

- new `auk_county()` filter
- new `auk_year()` filter
- Drop taxonomy warnings since there was no taxonomy update this year

# auk 0.4.1

- Family common names now included in eBird taxonomy
- `auk_select()` now requires certain columns to be kept
- Better handling of file paths with `prefix` argument in `auk_split()`
- Fixed bug causing undescribed species to be dropped by `auk_rollup()`
- Add a `ll_digits` argument to `filter_repeat_visits()` to round lat/lng prior to identifying sites
- Change of default parameters to `filter_repeat_visits()`
- `auk_bbox()` now takes sf/raster spatial objects and grabs bbox from them

# auk 0.4.0

- Updated to 2019 eBird taxonomy
- `auk_observer()` filter added
- `tidyr::complete_()` deprecated, stopped using

# auk 0.3.3

- Dates can now wrap in `auk_date()`, e.g. use `date = c("*-12-01", "*-01-31")` for records from December or January
- Fixed bug preventing dropping of `age/sex` column
- Allow for a wider variety of protocols in `auk_protocol()`
- Addresing some deprecated functions from rlang
- Fixed bug causing `auk_set_awk_path()` to fail

# auk 0.3.2

- Work around for bug in system2() in some R versions: https://bugs.r-project.org/bugzilla/show_bug.cgi?id=17508
- Adding a filter for PROALAS checklists to `auk_protocol()`

# auk 0.3.1

- `rlang::UQ()` and `rlang::UQS()` deprecated, switching to `!!` and `!!!`
- `auk_unique()` now keeps track of all sampling event and observer IDs that comprise a group checklist

# auk 0.3.0

- Updated to 2018 taxonomy; new function `get_ebird_taxonomy()` to get taxonomy via the eBird API
- Better handling of taxonomy versions, many functions now take a `taxonomy_version` argument and use the eBird API to get the taxonomy
- `auk_getpath()` renamed `auk_get_awk_path()`, and added `auk_set_awk_path()`
- Added `auk_set_ebd_path()` and `auk_get_ebd_path()` to set and get the 
`EBD_PATH` environment variable. Now users only need to set this once and just 
refer to the file name, rather than specifying the full path every time.
- Functions to prepare data for occupancy modeling: `filter_repeat_visits()` and `format_unmarked_occu()`
- New `auk_bcr()` function to extract data from BCRs
- Added `bcr_codes` data frame to look up BCR names and codes
- "Area" protocol added to `auk_protocol()` filter.
- `auk_extent()` renamed `auk_bbox()`; `auk_extent()` deprecated and redirects to `auk_bbox()`
- `auk_zerofill()` now checks for complete checklists and gives option to not rollup
- `auk_rollup()` now gives the option of keeping higher taxa via `drop_higher` argument
- `auk_clean()` deprecated
- Fixed package load error when `EBD_PATH` is invalid
- Fixed bug when reading files with a blank column using `readr`

# auk 0.2.2

- Updated to work with EDB version 1.9
- Modified tests to be more general to all sample data
- `ebird_species()` now returns 6-letter species codes
- Fixed bug causing auk to fail on files downloaded via custom download form
- Fixed bug with `normalizePath()` use on Windows
- Fixed bug with `system2()` on Windows

# auk 0.2.1

- Patch release fixing a couple bugs
- Removed all non-ASCII characters from example files, closes [issue #14](https://github.com/CornellLabofOrnithology/auk/issues/14)
- Fixed issue with state filtering not working, closes [issue $16](https://github.com/CornellLabofOrnithology/auk/issues/16)

# auk 0.2.0

- New function, `auk_split()`, splits EBD up into multiple files by species
- New object, `auk_sampling`, and associated methods for working with the sampling data only
- New function, `auk_select()`, for selecting a subset of columns
- `auk_date()` now allows filtering date ranges across years using wildcards, e.g. `date = c("*-05-01", "*-06-30")` for observations from May and June of any year
- New function, `auk_state()` for filtering by state
- Now using AWK arrays to speed up country and species filtering; ~20% speed up when filtering on many species/countries
- Allow selection of a subset of columns when filtering
- Remove free text columns in `auk_clean()` to decrease file size
- Updated to work with Feb 2018 version of EBD
- Fixed broken dependency on `countrycode` package

# auk 0.1.0

- eBird taxonomy update to August 2017 version, users should download the most recent EBD to ensure the taxonomy is in sync with the new package
- Manually set AWK path with environment variable `AWK_PATH` in `.Renviron` file 
- `auk_distance`, `auk_breeding`, `auk_protocol`, and `auk_project` filters added
- Users can now specify a subset of columns to return when calling auk_filter using the keep and drop arguments
- Many changes suggested by rOpenSci package peer review process, see https://github.com/ropensci/onboarding/issues/136 for details
- New vignette added to aid those wanting to contribute to package development

# auk 0.0.2

- Patch release converting ebird_taxonomy to ASCII to pass CRAN checks

# auk 0.0.1

- First CRAN release