#' Filter the eBird data by duration
#'
#' Define a filter for the eBird Basic Dataset (EBD) based on the duration of
#' the checklist. This function only defines the filter and, once all filters
#' have been defined, [auk_filter()] should be used to call AWK and perform the
#' filtering. Note that checklists with no effort, such as incidental 
#' observations, will be excluded if this filter is used since they have no 
#' associated duration information.
#'
#' @param x `auk_ebd` or `auk_sampling` object; reference to file created by 
#'   [auk_ebd()] or [auk_sampling()].
#' @param duration integer; 2 element vector specifying the range of durations
#'   in minutes to filter by.
#' 
#' @details This function can also work with on an `auk_sampling` object if the 
#'   user only wishes to filter the sampling event data.
#'
#' @return An `auk_ebd` object.
#' @export
#' @family filter
#' @examples
#' # only keep checklists that are less than an hour long
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_duration(duration = c(0, 60))
#'   
#' # alternatively, without pipes
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' auk_duration(ebd, duration = c(0, 60))
auk_duration <- function(x, duration)  {
  UseMethod("auk_duration")
}

#' @export
auk_duration.auk_ebd <- function(x, duration) {
  # checks
  assertthat::assert_that(
    length(duration) == 2,
    is.numeric(duration),
    duration[1] <= duration[2],
    all(duration >= 0)
  )

  # define filter
  x$filters$duration <- as.integer(round(duration))
  return(x)
}

#' @export
auk_duration.auk_sampling <- function(x, duration) {
  auk_duration.auk_ebd(x, duration)
}
