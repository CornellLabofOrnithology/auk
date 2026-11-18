# auk 0.10.0

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

# Test environments

- local OS X install, R 4.6
- OS X (github actions), R 4.6
- Windows (github actions), R 4.6
- ubuntu 14.04 (github actions), R 4.6
- win-builder (devel and release)

# R CMD check results

0 ERRORs | 0 WARNINGs | 0 NOTEs

## revdepcheck results

We checked 1 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 0 new problems
 * We failed to check 0 packages
