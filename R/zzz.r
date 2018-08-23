.onAttach <- function(libname, pkgname) {
  m <- paste0("%s functions with EBD files downloaded after %s.\n",
              "See ?auk_version_date for details.")
  p <- auk_get_ebd_path()
  if (is.na(p)) {
    m <- paste(m, "\nNo EBD data directory set, see ?auk_set_ebd_path to set",
               "EBD_PATH")
  } else {
    m <- paste(m, "\nEBD data directory: ", p)
  }
  packageStartupMessage(sprintf(m, "auk 0.2.3", "March 15, 2018"))
}
