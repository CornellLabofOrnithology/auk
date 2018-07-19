#' Filter the eBird data by last edited date
#'
#' Define a filter for the eBird Basic Dataset (EBD) based on a range of last
#' edited dates. Last edited date is typically used to extract just new or
#' recently edited data. This function only defines the filter and, once all
#' filters have been defined, [auk_filter()] should be used to call AWK and
#' perform the filtering.
#'
#' @param x `auk_ebd` or `auk_sampling` object; reference to file created by 
#'   [auk_ebd()] or [auk_sampling()].
#' @param date character or date; date range to filter by, provided either as a
#'   character vector in the format `"2015-12-31"` or a vector of Date objects.
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
#'   auk_last_edited(date = c("2010-01-01", "2010-12-31"))
auk_last_edited <- function(x, date)  {
  UseMethod("auk_last_edited")
}

#' @export
auk_last_edited.auk_ebd <- function(x, date) {
  # checks
  assertthat::assert_that(
    length(date) == 2,
    is.character(date) || assertthat::is.date(date),
    date[1] <= date[2]
  )

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
  x$filters$last_edited <- date
  return(x)
}

#' @export
auk_last_edited.auk_sampling <- function(x, date) {
  auk_last_edited.auk_ebd(x, date)
}
