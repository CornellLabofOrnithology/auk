#' Filter the eBird data by county
#'
#' Define a filter for the eBird Basic Dataset (EBD) based on a set of
#' counties This function only defines the filter and, once all filters have
#' been defined, [auk_filter()] should be used to call AWK and perform the
#' filtering.
#'
#' @param x `auk_ebd` or `auk_sampling` object; reference to file created by 
#'   [auk_ebd()] or [auk_sampling()].
#' @param county character; counties to filter by. eBird uses county codes
#'   consisting of three parts, the 2-letter ISO country code, a 1-3 character
#'   state code, and a county code, all separated by a dash. For example,
#'   `"US-NY-109"` corresponds to Tompkins, NY, US. The easiest way to find a
#'   county code is to find the corresponding [explore
#'   region](https://ebird.org/explore) page and look at the URL.
#' @param replace logical; multiple calls to `auk_county()` are additive,
#'   unless `replace = FALSE`, in which case the previous list of states to
#'   filter by will be removed and replaced by that in the current call.
#' 
#' @details It is not possible to filter by both county as well as country or
#'   state, so calling `auk_county()` will reset these filters to all countries
#'   and states, and vice versa.
#' 
#' This function can also work with on an `auk_sampling` object if the user only 
#' wishes to filter the sampling event data.
#'
#' @return An `auk_ebd` object.
#' @export
#' @family filter
#' @examples
#' # choose tompkins county, ny, united states
#' system.file("extdata/ebd-sample.txt", package = "auk") |>
#'   auk_ebd() |>
#'   auk_county("US-NY-109")
#'   
#' # alternatively, without pipes
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' auk_county(ebd, "US-NY-109")
auk_county <- function(x, county, replace = FALSE)  {
  UseMethod("auk_county")
}

#' @export
auk_county.auk_ebd <- function(x, county, replace = FALSE) {
  # checks
  assertthat::assert_that(
    is.character(county),
    assertthat::is.flag(replace)
  )
  county <- toupper(county)
  
  # add county to filter list
  if (replace) {
    x$filters$county <- county
  } else {
    x$filters$county <- c(x$filters$county, county)
  }
  x$filters$county <- sort(unique(x$filters$county))
  x$filters$state <- character()
  x$filters$country <- character()
  return(x)
}

#' @export
auk_county.auk_sampling <- function(x, county, replace = FALSE) {
  auk_county.auk_ebd(x, county, replace)
}