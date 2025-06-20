.onAttach <- function(libname, pkgname) {
  m <- paste0("%s is designed for EBD files downloaded after %s.")
  p <- auk_get_ebd_path()
  v <- auk_version()
  if (is.na(p)) {
    m <- paste(m, "\nNo EBD data directory set, see ?auk_set_ebd_path to set",
               "EBD_PATH")
  } else {
    m <- paste(m, "\nEBD data directory: ", p)
  }
  m <- paste(m, "\neBird taxonomy version: ", v$taxonomy_version)
  packageStartupMessage(sprintf(m, v$auk_version, v$ebd_version))
}
