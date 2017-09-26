#' Filter the eBird data by spatial extent
#'
#' Define a filter for the eBird Basic Dataset (EBD) based on spatial extent.
#' This function only defines the filter and, once all filters have been
#' defined, [auk_filter()] should be used to call AWK and perform the
#' filtering.
#'
#' @param x `auk_ebd` object; reference to object created by [auk_ebd()].
#' @param extent numeric; spatial extent expressed as the range of latitudes
#'   and longitudes in decimal degrees: `c(lng_min, lat_min, lng_max, lat_max)`.
#'
#' @return An `auk_ebd` object.
#' @export
#' @examples
#' # fliter to locations roughly in the Pacific Northwest
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_extent(extent = c(-125, 37, -120, 52))
#'   
#' # alternatively, without pipes
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' auk_extent(ebd, extent = c(-125, 37, -120, 52))
auk_extent <- function(x, extent)  {
  UseMethod("auk_extent")
}

#' @export
auk_extent.auk_ebd <- function(x, extent) {
  # checks
  assertthat::assert_that(
    is.numeric(extent),
    length(extent) == 4,
    extent[1] < extent[3],
    extent[2] < extent[4],
    extent[1] >= -180, extent[1] <= 180,
    extent[3] >= -180, extent[3] <= 180,
    extent[2] >= -90, extent[2] <= 90,
    extent[4] >= -90, extent[4] <= 90
  )

  # define filter
  x$filters$extent <- extent
  return(x)
}
