# auk 0.3.3

Fixes several two important bugs and a couple new features added:

- Dates can now wrap in `auk_date()`, e.g. use `date = c("*-12-01", "*-01-31")` for records from December or January
- Fixed bug preventing dropping of `age/sex` column
- Allow for a wider variety of protocols in `auk_protocol()`
- Addresing some deprecated functions from rlang
- Fixed bug causing `auk_set_awk_path()` to fail

# Test environments

- local OS X install, R 3.6.0
- OS X (travis-ci), R 3.5.2
- ubuntu 14.04 (travis-ci), R 3.5.2
- Windows (appveyor), R 3.5.2
- win-builder (devel and release)

# R CMD check results

0 ERRORs | 0 WARNINGs | 0 NOTEs
