#' Filter the eBird data by checklist start time
#'
#' Define a filter for the eBird Basic Dataset (EBD) based on a range of start
#' times for the checklist. This function only defines the filter and, once all
#' filters have been defined, [auk_filter()] should be used to call AWK and
#' perform the filtering.
#'
#' @param x `auk_ebd` or `auk_sampling` object; reference to file created by
#'   [auk_ebd()] or [auk_sampling()].
#' @param start_time character; 2 element character vector giving the range of
#'   times in 24 hour format, e.g. `"06:30"` or `"16:22"`.
#'
#' @details This function can also work with on an `auk_sampling` object if the
#'   user only wishes to filter the sampling event data.
#'
#' @return An `auk_ebd` object.
#' @export
#' @family filter
#' @examples
#' # only keep checklists started between 6 and 8 in the morning
#' system.file("extdata/ebd-sample.txt", package = "auk") |>
#'   auk_ebd() |>
#'   auk_time(start_time = c("06:00", "08:00"))
#'
#' # alternatively, without pipes
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' auk_time(ebd, start_time = c("06:00", "08:00"))
auk_time <- function(x, start_time) {
  UseMethod("auk_time")
}

#' @export
auk_time.auk_ebd <- function(x, start_time) {
  # checks
  assertthat::assert_that(
    length(start_time) == 2,
    is.character(start_time)
  )
  # check for valid times
  time_match <- stringr::str_match(
    start_time,
    "^([01]?\\d|2[0-3]):?([0-5]\\d)$"
  )
  if (anyNA(time_match[, 1])) {
    stop("Invalid time format.")
  }

  # normalize to zero-padded HH:MM, regardless of the input format, e.g.
  # "6:00", "600", and "06:00" should all become "06:00"
  start_time <- sprintf(
    "%02d:%s",
    as.integer(time_match[, 2]),
    time_match[, 3]
  )

  # check ordering of times makes sense
  assertthat::assert_that(start_time[1] <= start_time[2])

  # define filter
  x$filters$time <- start_time
  return(x)
}

#' @export
auk_time.auk_sampling <- function(x, start_time) {
  auk_time.auk_ebd(x, start_time)
}
