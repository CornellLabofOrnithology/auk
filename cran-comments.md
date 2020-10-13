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

# Test environments

- local OS X install, R 3.6.3
- OS X (travis-ci), R 3.6.3
- ubuntu 14.04 (travis-ci), R 3.6.3
- Windows (appveyor), R 3.6.3
- win-builder (devel and release)
- Rhub
  - Windows Server 2008 R2 SP1, R-devel, 32/64 bit
  - Ubuntu Linux 16.04 LTS, R-release, GCC
  - Fedora Linux, R-devel, clang, gfortran

# R CMD check results

0 ERRORs | 0 WARNINGs | 0 NOTEs
