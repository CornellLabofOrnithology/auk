# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this package does

`auk` is an R package that acts as a front end to the Unix utility AWK for
extracting and processing subsets of the eBird Basic Dataset (EBD) — a
very large (tens to hundreds of GB) tab-separated text file of bird
observation records. R itself is only used to build and validate filters;
the actual row filtering of the full dataset is done by generating and
running an AWK script, since reading the whole file into R is impractical.

## Common commands

Development workflow is driven from `makefile.R` (not a real Makefile — an R
script meant to be run line-by-line in an R session):

```r
devtools::document()        # regenerate man/ and NAMESPACE from roxygen comments
devtools::test()             # run the full test suite
devtools::check()            # full R CMD check
pkgdown::build_site()        # rebuild the pkgdown site in docs/
devtools::build_readme()     # regenerate README.md from README.Rmd
```

Run a single test file from an R session in the package root:

```r
testthat::test_file("tests/testthat/test_auk-filter.R")
```

Run a single `test_that()` block by temporarily adding `only_test = "..."`
or simply isolating it — there is no CLI equivalent to `devtools::test()`
for a single test name; use `devtools::load_all()` then call the test
file's contents directly, or filter with `devtools::test(filter = "filter")`
(matches test file names, e.g. `test_auk-filter.R`).

After changing any roxygen2 (`#'`) comment, re-run `devtools::document()`
— `man/*.Rd` and `NAMESPACE` are generated files, don't hand-edit them.

## Formatting and linting — always run these

- After writing or editing any `.R` file anywhere in the repo (`R/`,
  `tests/testthat/`, `data-raw/`), run `air format` on it (or
  `air format .` from the repo root — `air.toml` has no path
  restriction, so it reformats everything).
- After writing or editing any file in `R/`, run `jarl check R/` (or
  `jarl check .` — `jarl.toml`'s `lint.include = ["R/"]` restricts
  linting to `R/` regardless of the path given). `jarl` intentionally
  does not lint `tests/` or `data-raw/`. Fix obvious/auto-fixable issues
  with `jarl check --fix R/` (add `--allow-dirty` if the working tree
  already has unrelated uncommitted changes). For warnings that require
  judgment, use judgment rather than blindly forcing a fix.
- Do this on every change, not just when explicitly asked to format or
  lint.
- All package/test/maintainer-script source files use the `.R`
  extension (uppercase) — no `.r` files remain anywhere in the repo.
  Watch out for this repo's case-insensitive-filesystem gotcha: `git mv`
  between `foo.r` and `foo.R` can silently delete the file on disk
  instead of renaming it unless done as a two-step rename through a
  temporary name (`git mv foo.r foo.R.tmp && git mv foo.R.tmp foo.R`).
  Always verify with `git status`/`git diff --stat` after any rename or
  merge that touches case-only path changes, and restore any file that
  disappears via `git show HEAD:<path> > <path>`.

## Pipe operator

`auk` uses the native pipe `|>` exclusively — in code, docs, tests,
vignettes, and maintainer scripts. There is no magrittr `%>%` anywhere in
the package: the old `auk::%>%` re-export (`R/pipe.R`) and the `magrittr`
dependency were both removed, so this is a breaking change for any
downstream code still relying on `auk`'s re-exported `%>%`. `DESCRIPTION`
requires `R (>= 4.1.0)` to support `|>`. Avoid the `_` placeholder (which
needs R >= 4.2 and only binds to a single named argument) — for the rare
case where the pipe target isn't the first argument, use an intermediate
named variable instead (consistent with the general preference below
against pipes in function bodies).

## Architecture

### The filter pipeline

`auk` implements a pipeline/builder pattern around two S3 classes:

- **`auk_ebd`** (`R/auk-ebd.R`) — created by `auk_ebd(file, file_sampling)`.
  On construction it reads just the header row of the EBD (and, if given,
  the associated sampling event file) to validate that required columns
  are present and to build `col_idx` / `col_idx_sampling`: data frames
  mapping canonical filter ids (e.g. `"species"`, `"country"`, `"bcr"`) to
  the column name and 1-based column index in that specific file. Column
  indices matter because AWK scripts reference columns positionally
  (`$12`), and column order/presence varies between EBD file versions and
  custom downloads.
- **`auk_sampling`** (`R/auk-sampling.R`) — same idea, but for a
  checklist-only (sampling event) file with no species-level filters.

Each `auk_*()` filter function (`auk_species`, `auk_country`, `auk_state`,
`auk_county`, `auk_bcr`, `auk_bbox`, `auk_date`, `auk_last_edited`,
`auk_protocol`, `auk_project`, `auk_time`, `auk_duration`, `auk_distance`,
`auk_breeding`, `auk_complete`, `auk_exotic`, `auk_observer`, `auk_year`)
is an S3 generic dispatching on `auk_ebd`/`auk_sampling`. Each one
validates its input (e.g. species names checked against the bundled
`ebird_taxonomy` data, countries via the `countrycode` package, states via
`ebird_states`) and writes the validated value into `x$filters[[...]]`,
then returns the same object — this is what allows chaining with `|>`.
No actual file I/O happens at this stage.

`auk_filter()` (`R/auk-filter.R`) is where filters become reality:

1. `awk_translate()` walks `x$filters` and, for each non-empty filter,
   builds an AWK condition string (membership in a `split()`-built array
   for list filters like species/country/state/county/observer; numeric
   or string comparisons for ranges like date/time/duration/bbox) and
   substitutes them into the `awk_filter` script template using the
   package's own `str_interp()` (`${var}`-style interpolation, not
   `glue`/`stringr`).
2. The assembled AWK script is optionally written to `awk_file`.
3. `system2(awk_path, ...)` executes the script against `x$file` (and
   `x$file_sampling` if present) via a shell call, writing output to
   `file`/`file_sampling`. The `auk_ebd` object is returned with
   `output`/`output_sampling` populated with the result paths.

When both an EBD and a sampling file are present, `auk_filter.auk_ebd()`
builds and runs *two* AWK scripts so the two output files stay in sync —
with the species/breeding/exotic filters stripped out for the sampling
script (checklists aren't species-specific) and the `observer` filter's
`obsr` prefix rewritten to `obs` (the sampling file uses different ID
prefixes for observers).

### AWK location

`auk_get_awk_path()`/`auk_set_awk_path()` (`R/auk-get-awk-path.R`,
`R/auk-set-awk-path.R`) resolve the AWK binary, with special-casing for
Windows/Cygwin (expects `C:/cygwin/bin/gawk.exe` or `C:/cygwin64/...`) since
Windows has no AWK by default.

### Reading and post-processing

- `read_ebd()` / `read_sampling()` (`R/read.R`) read the AWK-filtered text
  output back into R with `readr`, applying correct column types via
  `get_col_types()` (`R/utils.R`) and renaming columns to `snake_case`.
- `auk_unique()` (`R/auk-unique.R`) collapses duplicate group checklists
  (shared checklists reported by multiple observers in a group).
- `auk_rollup()` (`R/auk-rollup.R`) rolls taxonomic reports up to species
  level (e.g. combining subspecies/forms, dropping "spuhs" if requested).
- `auk_zerofill()` (`R/auk-zerofill.R`) combines a filtered EBD with its
  matching sampling event file to infer absences, producing an
  `auk_zerofill` object (`list(observations, sampling_events)`, joinable
  on `checklist_id`) or, with `collapse = TRUE`, a single flattened data
  frame via `collapse_zerofill()`.
- `format_unmarked_occu()` (`R/format-unmarked-occu.R`) reshapes
  zero-filled data into the wide format expected by the `unmarked` package
  for occupancy modeling.

### Taxonomy data

`ebird_taxonomy`, `bcr_codes`, `ebird_states`, and `valid_protocols` are
bundled `data/*.rda` objects, built/updated from `data-raw/*.R` scripts.
Filters that reference species, BCRs, states, or protocols validate
against these tables rather than hitting the network. `auk_species()` and
`auk_zerofill()` accept a `taxonomy_version` argument — if it mismatches
the EBD file (detected via `auk_ebd_version()`/filename conventions) a
warning is raised, since species name resolution depends on taxonomy
version. `get_ebird_taxonomy()` (`R/get-ebird-taxonomy.R`) can fetch a
specific year's taxonomy from the eBird API when the bundled version
doesn't match.

## Testing notes

- Tests live in `tests/testthat/`, named `test_{name}.R` (not
  `test-{name}.R`, which is the testthat/usethis default elsewhere).
- `tests/testthat/setup.R` creates a shared `temp_dir` under `tempdir()`
  and preserves/restores `R_ENVIRON_USER` and `EBD_PATH` env vars around
  the whole run.
- Most filter/IO tests use the bundled sample data in `inst/extdata/`
  (`ebd-sample.txt`, `zerofill-ex_ebd.txt`, `zerofill-ex_sampling.txt`,
  `ebd-rollup-ex.txt`, `barchart-sample.txt`) rather than real/full EBD
  files.
- Tests that invoke AWK are skipped on CRAN and on Windows
  (`skip_on_cran()`, `skip_on_os("windows")`) since AWK isn't guaranteed
  to be installed/configured in those environments.
- CI (`.github/workflows/R-CMD-check.yaml`) runs on macOS, Windows, and
  multiple Ubuntu/R version combinations.
