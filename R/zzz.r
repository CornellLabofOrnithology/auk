.onAttach <- function(libname, pkgname) {
  m <- paste("This version of auk uses the %s eBird taxonomy\nWorking with an",
             "EBD file downloaded after %s may yield unexpected results\nTo",
             "get a current taxonomy, update auk with install.packages('auk')")
  tax_date <- auk_version_date()["taxonomy_date"]
  start_date <- format(as.Date(tax_date), "%b %Y")
  end_date <- format(as.Date(tax_date + 365), "%b %Y")
  packageStartupMessage(sprintf(m, start_date, end_date))
}
