.onAttach <- function(libname, pkgname) {
  m <- paste0("%s functions with EBD files downloaded after %s.\n",
              "See ?auk_version_date for details.")
  if (is.na(auk_get_ebd_path())) {
    m <- paste(m, "\nNo EBD data directory set, see ?auk_set_ebd_path to set",
               "EBD_PATH")
  } else {
    m <- paste(m, "\nEBD data directory: ", auk_get_ebd_path())
  }
  packageStartupMessage(sprintf(m, "auk 0.2.3", "March 15, 2018"))
}
