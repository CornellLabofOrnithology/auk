#' Lookup species in eBird taxonomy
#'
#' Given a list of common or scientific names, or species codes, check that they
#' appear in the official eBird taxonomy and convert them all to scientific
#' names, common names, or species codes. Un-matched species are returned as
#' `NA`.
#'
#' @param x character; species to look up, provided as scientific names, English
#'   common names, species codes, or a mixture of all three. Case insensitive.
#' @param type character; whether to return scientific names (`scientific`),
#'   English common names (`common`), or 6-letter eBird species codes (`code`). 
#'   Alternatively, use `all` to return a data frame with the all the taxonomy 
#'   information.
#' @param taxonomy_version integer; the version (i.e. year) of the taxonomy.
#'   Leave empty to use the version of the taxonomy included in the package.
#'   See [get_ebird_taxonomy()].
#'
#' @return Character vector of species identified by scientific name, common 
#'   name, or species code. If `type = "all"` a data frame of the taxonomy of 
#'   the requested species is returned.
#' @export
#' @family helpers
#' @examples
#' # mix common and scientific names, case-insensitive
#' species <- c("Blackburnian Warbler", "Poecile atricapillus",
#'              "american dipper", "Caribou", "hudgod")
#' # note that species not in the ebird taxonomy return NA
#' ebird_species(species)
#' 
#' # use taxonomy_version to query older taxonomy versions
#' \dontrun{
#' ebird_species("Cordillera Azul Antbird")
#' ebird_species("Cordillera Azul Antbird", taxonomy_version = 2017)
#' }
ebird_species <- function(x, type = c("scientific", "common", "code", "all"),
                          taxonomy_version) {
  assertthat::assert_that(is.character(x))
  type <- match.arg(type)
  
  # get the correct ebird taxonomy version
  if (missing(taxonomy_version) || 
      taxonomy_version == auk_version()$taxonomy_version) {
    tax <- auk::ebird_taxonomy
  } else {
    stopifnot(is_integer(taxonomy_version), length(taxonomy_version) == 1)
    tax <- get_ebird_taxonomy(version = taxonomy_version)
  }
  
  # deal with case issues
  lookup_species <- x
  x <- tolower(trimws(x))
  # convert to ascii
  x <- stringi::stri_trans_general(x, "latin-ascii")
  
  # first check for scientific names
  sci <- match(x, tolower(tax$scientific_name))
  # then for common names
  com <- match(x, tolower(tax$common_name))
  # finally for species codes
  sc <- match(x, tolower(tax$species_code))
  # combine
  idx <- ifelse(is.na(sci), ifelse(is.na(com), sc, com), sci)
  # convert to output format, default scientific
  if (identical(type, "scientific")) {
    return(tax$scientific_name[idx])
  } else if (identical(type, "common")) {
    return(tax$common_name[idx])
  } else if (identical(type, "code")) {
    return(tax$species_code[idx])
  } else {
    ret <- dplyr::as_tibble(tax[idx, ])
    ret$lookup_species <- lookup_species
    return(ret)
  }
}
