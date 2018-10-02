#' Lookup species in eBird taxonomy
#'
#' Given a list of common or scientific names, check that they appear in the
#' official eBird taxonomy and convert them all to scientific names, common
#' names, or species codes. Un-matched species are returned as `NA`.
#'
#' @param x character; species to look up, provided as scientific or
#'   English common names, or a mixture of both. Case insensitive.
#' @param type character; whether to return scientific names (`scientific`),
#'   English common names (`common`), or 6-letter eBird species codes (`code`).
#' @param version integer; the version (i.e. year) of the taxonomy. See 
#'   [get_ebird_taxonomy()].
#'
#' @return Character vector of species identified by scientific name, common 
#'   name, or species code.
#' @export
#' @family helpers
#' @examples
#' # mix common and scientific names, case-insensitive
#' species <- c("Blackburnian Warbler", "Poecile atricapillus",
#'              "american dipper", "Caribou")
#' # note that species not in the ebird taxonomy return NA
#' ebird_species(species)
#' 
#' # use version to query older taxonomy versions
#' ebird_species("Cordillera Azul Antbird")
#' ebird_species("Cordillera Azul Antbird", version = 2017)
ebird_species <- function(x, type = c("scientific", "common", "code"),
                          version) {
  assertthat::assert_that(is.character(x))
  type <- match.arg(type)
  
  # get the correct ebird taxonomy version
  if (missing(version) || version == auk_version()$taxonomy_version) {
    tax <- auk::ebird_taxonomy
  } else {
    assertthat::assert_that(
      is_integer(version), 
      length(version) == 1)
    tax <- get_ebird_taxonomy(version = version)
  }
  
  # deal with case issues
  x <- tolower(trimws(x))
  # convert to ascii
  x <- stringi::stri_trans_general(x, "latin-ascii")
  
  # first check for scientific names
  sci <- match(x, tolower(tax$scientific_name))
  # then for common names
  com <- match(x, tolower(tax$common_name))
  # combine
  idx <- ifelse(is.na(sci), com, sci)
  # convert to output format, default scientific
  if (identical(type, "scientific")) {
    return(tax$scientific_name[idx])
  } else if (identical(type, "common")) {
    return(tax$common_name[idx])
  } else {
    return(tax$species_code[idx])
  }
}
