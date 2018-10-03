#' Filter the eBird data by species
#'
#' Define a filter for the eBird Basic Dataset (EBD) based on species. This
#' function only defines the filter and, once all filters have been defined,
#' [auk_filter()] should be used to call AWK and perform the filtering.
#'
#' @param x `auk_ebd` object; reference to object created by [auk_ebd()].
#' @param species character; species to filter by, provided as scientific or
#'   English common names, or a mixture of both. These names must match the
#'   official eBird Taxomony ([ebird_taxonomy]).
#' @param taxonomy_version integer; the version (i.e. year) of the taxonomy. In
#'   most cases, this should be left empty to use the version of the taxonomy
#'   included in the package. See [get_ebird_taxonomy()].
#' @param replace logical; multiple calls to `auk_species()` are additive, 
#'   unless `replace = FALSE`, in which case the previous list of species to 
#'   filter by will be removed and replaced by that in the current call.
#'   
#' @details The list of species is checked against the eBird taxonomy for
#'   validity. This taxonomy is updated once a year in August. The `auk` package 
#'   includes a copy of the eBird taxonomy, current at the time of release; 
#'   however, if the EBD and `auk` versions are not aligned, you may need to 
#'   explicitly specify which version of the taxonomy to use, in which case 
#'   the eBird API will be queried to get the correct version of the taxonomy. 
#'
#' @return An `auk_ebd` object.
#' @export
#' @family filter
#' @examples
#' # common and scientific names can be mixed
#' species <- c("Canada Jay", "Pluvialis squatarola")
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_species(species)
#'   
#' # alternatively, without pipes
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' auk_species(ebd, species)
auk_species <- function(x, species, taxonomy_version, replace = FALSE)  {
  UseMethod("auk_species")
}

#' @export
auk_species.auk_ebd <- function(x, species, taxonomy_version, replace = FALSE) {
  # checks
  assertthat::assert_that(
    is.character(species),
    assertthat::is.flag(replace)
  )
  if (missing(taxonomy_version)) {
    taxonomy_version <- auk_version()$taxonomy_version
  } else {
    stopifnot(is_integer(taxonomy_version), length(taxonomy_version) == 1)
  }
  v <- auk_ebd_version(x, check_exists = FALSE)$taxonomy_version
  if (!is.na(v) && taxonomy_version != v) {
    m <- paste0("Based on the EBD filename, it appears you should use ",
                "taxonomy_version = %i")
    warning(sprintf(m, v))
  }
  species_lookup <- ebird_species(species, type = "all", 
                                  taxonomy_version = taxonomy_version)

  # check all species names are valid
  species_clean <- species_lookup$scientific_name
  if (any(is.na(species_clean))) {
    stop(
      paste0("The following species were not found in the eBird taxonomy: \n\t",
             paste(species[is.na(species_clean)], collapse = ", "))
    )
  }
  
  # check all species names are valid
  sub_spp <- species_lookup$category %in% c("issf", "form", "intergrade")
  if (any(sub_spp)) {
    stop(
      paste0("Cannot extract taxa identified below species.\n\t",
             "Remove the following taxa or replace with species: \n\t",
             paste(species[sub_spp], collapse = ", "))
    )
  }
  
  # add species to filter list
  if (replace) {
    x$filters$species <- species_clean
  } else {
    x$filters$species <- c(x$filters$species, species_clean)
  }
  x$filters$species <- c(x$filters$species, species_clean) %>%
    unique() %>%
    sort()
  return(x)
}
