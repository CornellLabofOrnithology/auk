# Patch release

- removed all non-ASCII characters from package to pass CRAN checks

# Test environments

- local OS X install, R 3.3.3
- OS X (on travis-ci), R 3.3.3
- ubuntu 14.04 (on travis-ci), R 3.3.3
- Windows (appveyor), R 3.3.3
- win-builder

# R CMD check results

There were no ERROR or WARNINGs.

There was 1 NOTE:

* checking CRAN incoming feasibility ... NOTE
  Maintainer: ‘Matthew Strimas-Mackey <mes335@cornell.edu>’
  Days since last update: 0
  
  First submission failed checks on binary build, this patch fixes errors.
  