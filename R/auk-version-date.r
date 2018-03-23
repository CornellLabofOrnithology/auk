#' Dates of eBird Basic Dataset and taxonomy in package version
#'
#' This package depends on the version of the EBD and on the eBird taxonomy. Use
#' this function to determine the version dates for which the package is
#' suitable. The EBD is update quarterly (March 15, June 15, September 15, 
#' December 15), while the taxonomy is updated annually in September. To ensure 
#' proper functioning, always use the latest version of the auk package and the 
#' EBD.
#'
#' @return A date vector with the eBird data date and taxonomy date that this 
#'   version of the package corresponds to.
#' @export
#' @examples
#' auk_version_date()
auk_version_date <- function() {
  c(edb_date = as.Date("2018-03-15"), taxonomy_date = as.Date("2017-08-17"))
}
