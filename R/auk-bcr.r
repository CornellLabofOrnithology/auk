#' Filter the eBird data by Bird Conservation Region
#'
#' Define a filter for the eBird Basic Dataset (EBD) to extract data for a set
#' of [Bird Conservation
#' Regions](http://nabci-us.org/resources/bird-conservation-regions/) (BCRs).
#' BCRs are ecologically distinct regions in North America with similar bird
#' communities, habitats, and resource management issues. This function only
#' defines the filter and, once all filters have been defined, [auk_filter()]
#' should be used to call AWK and perform the filtering.
#' 
#' @param x `auk_ebd` or `auk_sampling` object; reference to file created by 
#'   [auk_ebd()] or [auk_sampling()].
#' @param bcr integer; BCRs to filter by. BCRs are identified by an integer, 
#'   from 1 to 66, that can be looked up in the [bcr_codes] table.
#' @param replace logical; multiple calls to `auk_state()` are additive,
#'   unless `replace = FALSE`, in which case the previous list of states to
#'   filter by will be removed and replaced by that in the current call.
#' 
#' @details This function can also work with on an `auk_sampling` object if the 
#' user only wishes to filter the sampling event data.
#'
#' @return An `auk_ebd` object.
#' @export
#' @family filter
#' @examples
#' # bcr codes can be looked up in bcr_codes
#' dplyr::filter(bcr_codes, bcr_name == "Central Hardwoods")
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_bcr(bcr = 24)
#'   
#' # alternatively, without pipes
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' auk_bcr(ebd, bcr = 24)
auk_bcr <- function(x, bcr, replace = FALSE)  {
  UseMethod("auk_bcr")
}

#' @export
auk_bcr.auk_ebd <- function(x, bcr, replace = FALSE) {
  # checks
  assertthat::assert_that(
    all(is_integer(bcr)),
    all(bcr %in% auk::bcr_codes$bcr_code),
    assertthat::is.flag(replace)
  )
  bcr <- as.integer(bcr)
  
  # check for bcr column
  if (!"bcr" %in% x$col_idx$id) {
    stop("BCR column missing from EBD")
  }
  if (!is.null(x$col_idx_sampling) && !"bcr" %in% x$col_idx_sampling$id) {
    stop("BCR column missing from sampling event data")
  }
  
  # set filter list
  if (replace) {
    x$filters$bcr <- bcr
  } else {
    x$filters$bcr <- c(x$filters$bcr, bcr)
  }
  x$filters$bcr <- sort(unique(x$filters$bcr))
  return(x)
}

#' @export
auk_bcr.auk_sampling <- function(x, bcr, replace = FALSE) {
  auk_bcr.auk_ebd(x, bcr, replace)
}
