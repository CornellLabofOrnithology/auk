#' Filter the eBird data by protocol
#'
#' Filter to just data collected following a specific search protocol:
#' stationary, traveling, or casual. This function only defines the filter and,
#' once all filters have been defined, [auk_filter()] should be used to call AWK
#' and perform the filtering.
#'
#' @param x `auk_ebd` or `auk_sampling` object; reference to file created by 
#'   [auk_ebd()] or [auk_sampling()].
#' @param protocol character. Many protocols exist in the database, however, the
#'   most commonly used are:
#'   
#'   - Stationary
#'   - Traveling
#'   - Area
#'   - Incidental
#'   
#'   A complete list of valid protocols is contained within the vector 
#'   `valid_protocols` within this package. Multiple protocols are allowed at 
#'   the same time.
#' 
#' @details This function can also work with on an `auk_sampling` object if the 
#'   user only wishes to filter the sampling event data.
#'
#' @return An `auk_ebd` object.
#' @export
#' @family filter
#' @examples
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_protocol("Stationary")
#'   
#' # alternatively, without pipes
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' auk_protocol(ebd, "Stationary")
auk_protocol <- function(x, protocol)  {
  UseMethod("auk_protocol")
}

#' @export
auk_protocol.auk_ebd <- function(x, protocol) {
  assertthat::assert_that(
    all(protocol %in% auk::valid_protocols)
  )
  
  # set filter list
  x$filters$protocol <- protocol
  return(x)
}

#' @export
auk_protocol.auk_sampling <- function(x, protocol) {
  auk_protocol.auk_ebd(x, protocol)
}