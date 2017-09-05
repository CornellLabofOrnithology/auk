#' Filter out incomplete checklists from the eBird data
#'
#' Define a filter for the eBird Basic Dataset (EBD) to only keep complete
#' checklists, i.e. those for which all birds seen or heard were recorded. These
#' checklists are the most valuable for scientific uses since they provide
#' presence and absence data.This function only defines the filter and, once all
#' filters have been defined, [auk_filter()] should be used to call AWK and
#' perform the filtering.
#'
#' @param x `auk_ebd` object; reference to basic dataset file created by [auk_ebd()].
#'
#' @return An `auk_ebd` object.
#' @export
#' @examples
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_complete()
auk_complete <- function(x)  {
  UseMethod("auk_complete")
}

#' @export
auk_complete.auk_ebd <- function(x) {
  # define filter
  x$filters$complete <- TRUE
  return(x)
}
