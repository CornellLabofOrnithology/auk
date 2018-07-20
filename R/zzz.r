.onAttach <- function(libname, pkgname) {
  m <- paste0("%s functions with EBD files downloaded after %s.\n",
              "See ?auk_version_date for details.")
  #auk_version <- utils::paste("auk", packageVersion("auk"))
  #tax_date <- auk_version_date()["taxonomy_date"]
  #start_date <- format(as.Date(tax_date), "%b %Y")
  #end_date <- format(as.Date(tax_date + 365), "%b %Y")
  packageStartupMessage(sprintf(m, "auk 0.2.2", "March 15, 2018"))
}
