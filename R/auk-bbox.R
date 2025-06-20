#' Filter the eBird data by spatial bounding box
#'
#' Define a filter for the eBird Basic Dataset (EBD) based on spatial bounding
#' box. This function only defines the filter and, once all filters have been
#' defined, [auk_filter()] should be used to call AWK and perform the filtering.
#'
#' @param x `auk_ebd` or `auk_sampling` object; reference to file created by 
#'   [auk_ebd()] or [auk_sampling()].
#' @param bbox numeric or `sf` or `Raster*` object; spatial bounding box
#'   expressed as the range of latitudes and longitudes in decimal degrees:
#'   `c(lng_min, lat_min, lng_max, lat_max)`. Note that longitudes in the
#'   Western Hemisphere and latitudes sound of the equator should be given as
#'   negative numbers. Alternatively, a spatial object from either the `sf` or 
#'   `raster` packages can be provided and the bounding box will be extracted 
#'   from this object.
#' 
#' @details This function can also work with on an `auk_sampling` object if the 
#'   user only wishes to filter the sampling event data.
#'
#' @return An `auk_ebd` object.
#' @export
#' @family filter
#' @examples
#' # fliter to locations roughly in the Pacific Northwest
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_bbox(bbox = c(-125, 37, -120, 52))
#'   
#' # alternatively, without pipes
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' auk_bbox(ebd, bbox = c(-125, 37, -120, 52))
auk_bbox <- function(x, bbox)  {
  UseMethod("auk_bbox")
}

#' @export
auk_bbox.auk_ebd <- function(x, bbox) {
  # process spatial objects
  if (inherits(bbox, c("sf", "sfc", "Raster"))) {
    if (requireNamespace("sf", quietly = TRUE)) {
      bb <- sf::st_as_sfc(sf::st_bbox(bbox))
      bb <- sf::st_set_crs(bb, value = sf::st_crs(bbox))
      bb <- sf::st_bbox(sf::st_transform(bb, crs = 4326))
      bbox <- c(bb["xmin"], bb["ymin"], bb["xmax"], bb["ymax"]) 
    } else {
      stop("To use sf or raster objects as bbox, install the sf package.")
    } 
  }
  # checks
  assertthat::assert_that(
    is.numeric(bbox),
    length(bbox) == 4,
    bbox[1] < bbox[3],
    bbox[2] < bbox[4],
    bbox[1] >= -180, bbox[1] <= 180,
    bbox[3] >= -180, bbox[3] <= 180,
    bbox[2] >= -90, bbox[2] <= 90,
    bbox[4] >= -90, bbox[4] <= 90
  )

  # define filter
  x$filters$bbox <- bbox
  return(x)
}

#' @export
auk_bbox.auk_sampling <- function(x, bbox) {
  auk_bbox.auk_ebd(x, bbox)
}

#' Filter the eBird data by spatial extent
#' 
#' **Deprecated**, use [auk_bbox()] instead.
#'
#' @param x `auk_ebd` or `auk_sampling` object; reference to file created by 
#'   [auk_ebd()] or [auk_sampling()].
#' @param extent numeric; spatial extent expressed as the range of latitudes and
#'   longitudes in decimal degrees: `c(lng_min, lat_min, lng_max, lat_max)`.
#'   Note that longitudes in the Western Hemisphere and latitudes sound of the
#'   equator should be given as negative numbers.
#'
#' @return An `auk_ebd` object.
#' @export
#' @family filter
#' @examples
#' # fliter to locations roughly in the Pacific Northwest
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_bbox(bbox = c(-125, 37, -120, 52))
#'   
#' # alternatively, without pipes
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' auk_bbox(ebd, bbox = c(-125, 37, -120, 52))
auk_extent <- function(x, extent) {
  .Deprecated("auk_bbox")
  auk_bbox(x, bbox = extent)
}