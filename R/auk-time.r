#' Filter the EBD by checklist start time
#'
#' Define a filter for the eBird Basic Dataset (EBD) based on a range of start
#' times for the checklist. This function only defines the filter and, once all
#' filters have been defined, [auk_filter()] should be used to call AWK and
#' perform the filtering.
#'
#' @param x `auk_ebd` object; reference to EBD file created by [auk_ebd()].
#' @param time character; 2 element character vector giving the range of times
#'   in 24 hour format, e.g. `"06:30"` or `"16:22"`.
#'
#' @return An `auk_ebd` object.
#' @export
#' @examples
#' # only keep checklists started between 6 and 8 in the morning
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_time(time = c("06:00", "08:00"))
auk_time <- function(x, time)  {
  UseMethod("auk_time")
}

#' @export
auk_time.auk_ebd <- function(x, time) {
  # checks
  assertthat::assert_that(
    length(time) == 2,
    is.character(time)
  )
  # check for valid times
  if (!all(stringr::str_detect(time, "^([01]?\\d|2[0-3]):?([0-5]\\d)$"))) {
    stop("Invalid time format.")
  }

  # add optional 0 at start
  time <- paste0(ifelse(nchar(time) == 4, "0", ""), time)

  # check ordering of times makes sense
  assertthat::assert_that(time[1] <= time[2])

  # define filter
  x$filters$time <- time
  return(x)
}
