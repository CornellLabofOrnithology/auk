#' Filter eBird data by distance travelled
#'
#' Define a filter for the eBird Basic Dataset (EBD) based on the distance
#' travelled on the checklist. This function only defines the filter and, once
#' all filters have been defined, [auk_filter()] should be used to call AWK and
#' perform the filtering. Note that stationary checklists (i.e. point counts) 
#' have no distance associated with them, however, since these checklists can 
#' be assumed to have 0 distance they will be kept if 0 is in the range defined 
#' by `distance`.
#'
#' @param x `auk_ebd` or `auk_sampling` object; reference to file created by 
#'   [auk_ebd()] or [auk_sampling()].
#' @param distance integer; 2 element vector specifying the range of distances
#'   to filter by. The default is to accept distances in kilometers, use 
#'   `distance_units = "miles"` for miles.
#' @param distance_units character; whether distances are provided in kilometers 
#'   (the default) or miles.
#' 
#' @details This function can also work with on an `auk_sampling` object if the 
#'   user only wishes to filter the sampling event data.
#'
#' @return An `auk_ebd` object.
#' @export
#' @family filter
#' @examples
#' # only keep checklists that are less than 10 km long
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_distance(distance = c(0, 10))
#'   
#' # alternatively, without pipes
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' auk_distance(ebd, distance = c(0, 10))
auk_distance <- function(x, distance, distance_units)  {
  UseMethod("auk_distance")
}

#' @export
auk_distance.auk_ebd <- function(x, distance, 
                                 distance_units = c("km", "miles")) {
  # checks
  assertthat::assert_that(
    length(distance) == 2,
    is.numeric(distance),
    distance[1] <= distance[2],
    all(distance >= 0)
  )
  
  # convert to kilometers
  distance_units <- match.arg(distance_units)
  if (distance_units == "miles") {
    distance <- 1.60934 * distance
  }
  
  # define filter
  x$filters$distance <- distance
  return(x)
}

#' @export
auk_distance.auk_sampling <- function(x, distance, 
                                      distance_units = c("km", "miles")) {
  auk_distance.auk_ebd(x, distance, distance_units)
}
