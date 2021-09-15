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