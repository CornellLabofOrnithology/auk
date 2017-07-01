#' Dates of EBD and Taxonomy in package version
#'
#' This package depends on the version of the EBD and on the eBird taxonomy. Use
#' this function to determine the version dates for which the package is
#' suitable.
#'
#' @return A date vector with the EBD date and taxonomy date that this version
#'   of the package corresponds to.
#' @export
#' @examples
#' auk_version_date()
auk_version_date <- function() {
  c(edb_date = as.Date("2017-05-01"), taxonomy_date = as.Date("2016-08-09"))
}
