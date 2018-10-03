# auk 0.3.0

This version includes several bug fixes, many new features, and modifications to work with the 2018 eBird Reference Dataset:

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

# Test environments

- local OS X install, R 3.5.1
- OS X (travis-ci), R 3.5.0
- ubuntu 14.04 (travis-ci), R 3.5.0
- ubuntu 14.04 (travis-ci), R 3.4.4
- Windows (appveyor), R 3.5.1
- win-builder

# R CMD check results

0 ERRORs | 0 WARNINGs | 0 NOTEs
