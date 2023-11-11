# the contents of this file are run once for all tests
temp_dir <- file.path(tempdir(), "auk_temp_dir")
dir.create(temp_dir, recursive = TRUE, showWarnings = FALSE)
old_renv <- Sys.getenv("R_ENVIRON_USER")
old_ebd <- Sys.getenv("EBD_PATH")

# cleanup the mess we made above
cleanup <- function() {
  unlink(temp_dir, recursive = TRUE)
  Sys.setenv(R_ENVIRON_USER = old_renv)
  Sys.setenv(EBD_PATH = old_ebd)
}
# run cleanup after tests are complete
withr::defer(cleanup(), teardown_env())

