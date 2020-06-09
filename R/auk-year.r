#' Filter the eBird data to a set of years
#'
#' Define a filter for the eBird Basic Dataset (EBD) based on a set of
#' years. This function only defines the filter and, once all filters have
#' been defined, [auk_filter()] should be used to call AWK and perform the
#' filtering.
#'
#' @param x `auk_ebd` or `auk_sampling` object; reference to file created by 
#'   [auk_ebd()] or [auk_sampling()].
#' @param year integer; years to filter to.
#' @param replace logical; multiple calls to `auk_year()` are additive,
#'   unless `replace = FALSE`, in which case the previous list of years to
#'   filter by will be removed and replaced by that in the current call.
#' 
#' @details For filtering to a range of dates use `auk_date()`; however,
#'   sometimes the goal is to extract data for a given year or set of years, in
#'   which case `auk_year()` is simpler. In addition, `auk_year()` can be used
#'   to get data from discontiguous sets of years (e.g. 2010 and 2012, but not
#'   2011), which is not possible with `auk_date()`. Finally, `auk_year()` can
#'   be used in conjunction with `auk_date()` to extract data from a given range
#'   of dates within a set of years (see example below).
#'   
#'   This function can also work with on an `auk_sampling` object if the user
#'   only wishes to filter the sampling event data.
#'
#' @return An `auk_ebd` object.
#' @export
#' @family filter
#' @examples
#' # years to filter to
#' years <- c(2010, 2012)
#' # set up filter
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_year(year = years)
#'   
#' # alternatively, without pipes
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' auk_year(ebd, years)
#' 
#' # filter to may and june of 2010 and 2012
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_year(year = c(2010, 2012)) %>% 
#'   auk_date(date = c("*-05-01", "*-06-30"))
auk_year <- function(x, year, replace = FALSE)  {
  UseMethod("auk_year")
}

#' @export
auk_year.auk_ebd <- function(x, year, replace = FALSE) {
  # checks
  assertthat::assert_that(
    is_integer(year),
    all(year %in% 1800:2100)
  )
  
  # add yeras to filter list
  if (replace) {
    x$filters$year <- year
  } else {
    x$filters$year <- c(x$filters$year, year)
  }
  x$filters$year <- sort(unique(x$filters$year))
  return(x)
}

#' @export
auk_year.auk_sampling <- function(x, year, replace = FALSE) {
  auk_year.auk_ebd(x, year, replace)
}