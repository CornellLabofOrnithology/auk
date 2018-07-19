#' Filter the eBird data by date
#'
#' Define a filter for the eBird Basic Dataset (EBD) based on a range of dates.
#' This function only defines the filter and, once all filters have been
#' defined, [auk_filter()] should be used to call AWK and perform the
#' filtering.
#'
#' @param x `auk_ebd` or `auk_sampling` object; reference to file created by 
#'   [auk_ebd()] or [auk_sampling()].
#' @param date character or date; date range to filter by, provided either as a
#'   character vector in the format `"2015-12-31"` or a vector of Date objects. 
#'   To filter on a range of dates, regardless of year, use `"*"` in place of 
#'   the year.
#' 
#' @details To select observations from a range of dates, regardless of year, 
#' the  wildcard `"*"` can be used in place of the year. For example, using 
#' `date = c("*-05-01", "*-06-30")` will return observations from May and June 
#' of *any year*.
#' 
#' This function can also work with on an `auk_sampling` object if the user only 
#' wishes to filter the sampling event data.
#'
#' @return An `auk_ebd` object.
#' @export
#' @family filter
#' @examples
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_date(date = c("2010-01-01", "2010-12-31"))
#'   
#' # alternatively, without pipes
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' auk_date(ebd, date = c("2010-01-01", "2010-12-31"))
#' 
#' # the * wildcard can be used in place of year to select dates from all years
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   # may-june records from all years
#'   auk_date(date = c("*-05-01", "*-06-30"))
auk_date <- function(x, date)  {
  UseMethod("auk_date")
}

#' @export
auk_date.auk_ebd <- function(x, date) {
  # checks
  assertthat::assert_that(
    length(date) == 2,
    is.character(date) || assertthat::is.date(date),
    date[1] <= date[2]
  )
  
  # check for wildcard in year
  has_wildcard <- stringr::str_detect(date, "^\\*-[0-9]{1,2}-[0-9]{1,2}")
  if (all(has_wildcard)) {
    # temporarily replace wildcard with 2016
    date <- stringr::str_replace(date, "^\\*", "2016")
  } else if (!all(!has_wildcard)) {
    stop("Cannot mix wildcard dates with non-wildcard dates.")
  }

  # convert to date object, then format as ISO standard date format
  date <- as.Date(date) %>%
    format("%Y-%m-%d")
  
  assertthat::assert_that(
    all(!is.na(date)),
    date[1] <= date[2],
    date[1] >= "1850-01-01",
    date[2] >= "1850-01-01"
  )

  # define filter
  if (all(has_wildcard)) {
    x$filters$date <- stringr::str_replace(date, "^2016", "*")
    attr(x$filters$date, "wildcard") <- TRUE
  } else {
    x$filters$date <- date
    attr(x$filters$date, "wildcard") <- FALSE
  }
  
  return(x)
}

#' @export
auk_date.auk_sampling <- function(x, date) {
  auk_date.auk_ebd(x, date)
}
