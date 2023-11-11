#' Filter the eBird data by exotic code
#'
#' Exotic codes are applied to eBird observations when the species is believe to
#' be non-native to the given location. This function defines a filter for the
#' eBird Basic Dataset (EBD) to subset observations to one or more of the exotic
#' codes: "" (i.e. no code, meaning it is a native species), "N" (naturalized),
#' "P" (provisional), or "X" (escapee). This function only defines the filter
#' and, once all filters have been defined, [auk_filter()] should be used to
#' call AWK and perform the filtering.
#' 
#' @param x `auk_ebd` or `auk_sampling` object; reference to file created by 
#'   [auk_ebd()] or [auk_sampling()].
#' @param exotic_code characterr; exotic codes to filter by. Note that an empty
#'   string (""), meaning no exotic code, is used for native species.
#' @param replace logical; multiple calls to `auk_exotic()` are additive,
#'   unless `replace = FALSE`, in which case the previous list of states to
#'   filter by will be removed and replaced by that in the current call.
#'
#' @return An `auk_ebd` object.
#' @export
#' @family filter
#' @examples
#' # filter to only native observations
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' auk_exotic(ebd, exotic_code = "")
#' 
#' # filter to native and naturalized observations
#' auk_exotic(ebd, exotic_code = c("", "N"))
auk_exotic <- function(x, exotic_code, replace = FALSE)  {
  UseMethod("auk_exotic")
}

#' @export
auk_exotic.auk_ebd <- function(x, exotic_code, replace = FALSE) {
  # checks
  assertthat::assert_that(
    all(exotic_code %in% c("", "N", "P", "X")),
    assertthat::is.flag(replace)
  )
  
  # check for bcr column
  if (!"exotic" %in% x$col_idx$id) {
    stop("Exotic code column missing from EBD")
  }
  
  # set filter list
  if (replace) {
    x$filters$exotic <- exotic_code
  } else {
    x$filters$exotic <- c(x$filters$exotic, exotic_code)
  }
  x$filters$exotic <- sort(unique(x$filters$exotic))
  return(x)
}