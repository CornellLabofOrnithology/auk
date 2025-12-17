#' Filter to only include observations with breeding codes
#'
#' eBird users have the option of specifying breeding bird atlas codes for their
#' observations, for example, if nesting building behaviour is observed. Use
#' this filter to select only those observations with an associated breeding
#' code. This function only defines the filter and, once all filters have been
#' defined, [auk_filter()] should be used to call AWK and perform the filtering.
#'
#' @param x `auk_ebd` object; reference to basic dataset file created by
#'   [auk_ebd()].
#'
#' @return An `auk_ebd` object.
#' @export
#' @family filter
#' @examples
#' system.file("extdata/ebd-sample.txt", package = "auk") |>
#'   auk_ebd() |>
#'   auk_breeding()
auk_breeding <- function(x)  {
  UseMethod("auk_breeding")
}

#' @export
auk_breeding.auk_ebd <- function(x) {
  # check for breeding code column
  if (!"breeding" %in% x$col_idx$id) {
    stop("Breeding code column missing from EBD")
  }
  
  # define filter
  x$filters$breeding <- TRUE
  return(x)
}
