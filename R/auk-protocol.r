#' Filter the eBird data by protocol
#'
#' Filter to just data collected following a specific search protocol:
#' stationary, traveling, or casual. This function only defines the filter and,
#' once all filters have been defined, [auk_filter()] should be used to call AWK
#' and perform the filtering.
#'
#' @param x `auk_ebd` object; reference to object created by [auk_ebd()].
#' @param protocol character; "stationary", "traveling", or "causal". Other 
#'   protocols exist in the database, however, this function only extracts these 
#'   three standard protocols.
#'
#' @return An `auk_ebd` object.
#' @export
#' @examples
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_protocol("stationary")
#'   
#' # alternatively, without pipes
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' auk_protocol(ebd, "stationary")
auk_protocol <- function(x, protocol)  {
  UseMethod("auk_protocol")
}

#' @export
auk_protocol.auk_ebd <- function(x, protocol) {
  assertthat::assert_that(
    all(protocol %in% c("stationary", "traveling", "casual"))
  )
  
  # set filter list
  x$filters$protocol <- protocol
  return(x)
}
