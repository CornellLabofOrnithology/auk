#' Lookup species in eBird taxonomy
#'
#' Given a list of common or scientific names, check that they appear in the
#' official eBird taxonomy and convert them all to scientific names, or common
#' names if `scientific = FALSE`. Un-matched species are returned as `NA`.
#'
#' @param x character; species to look up, provided as scientific or
#'   English common names, or a mixture of both. Case insensitive.
#' @param scientific logical; whether to return scientific (`TRUE`) or English
#'   common names (`FALSE`).
#'
#' @return Character vector of scientific names or common names if names if
#'   `scientific = FALSE`.
#' @export
#' @examples
#' # mix common and scientific names, case-insensitive
#' species <- c("Blackburnian Warbler", "Poecile atricapillus",
#'              "american dipper", "Caribou")
#' # species not in the ebird taxonomy return NA
#' ebird_species(species)
ebird_species <- function(x, scientific = TRUE) {
  assertthat::assert_that(is.character(x))

  # deal with case issues
  x <- tolower(trimws(x))
  # first check for scientific names
  sci <- match(x, tolower(ebird_taxonomy$name_scientific))
  # then for common names
  com <- match(x, tolower(ebird_taxonomy$name_common))
  # combine
  idx <- ifelse(is.na(sci), com, sci)
  # convert to output format, default scientific
  if (scientific)  {
    return(ebird_taxonomy$name_scientific[idx])
  } else {
    return(ebird_taxonomy$name_common[idx])
  }
}
