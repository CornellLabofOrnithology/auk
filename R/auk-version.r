#' Versions of auk, the EBD, and the eBird taxonomy
#'
#' This package depends on the version of the EBD and on the eBird taxonomy. Use
#' this function to determine the currently installed version of `auk`, the 
#' version of the EBD that this `auk` version works with, and the version of the 
#' eBird taxonomy included in the packages. The EBD is update quarterly, in 
#' March, June, September, and December, while the taxonomy is updated annually 
#' in August or September. To ensure proper functioning, always use the latest 
#' version of the auk package and the EBD.
#'
#' @return A list with three elements:
#'   
#'   - `auk_version`: the version of `auk`, e.g. `"auk 0.4.1"`.
#'   - `ebd_version`: a date object specifying the release date of the EBD 
#'   version that this `auk` version is designed to work with.
#'   - `taxonomy_version`: the year of the taxonomy built in to this version of 
#'   `auk`, i.e. the one stored in [ebird_taxonomy].
#'   
#' @export
#' @family helpers
#' @examples
#' auk_version()
auk_version <- function() {
  list(auk_version = "auk 0.7.0",
       ebd_version = as.Date("2023-10-25", "%Y-%m-%d"), 
       taxonomy_version = 2023)
}
