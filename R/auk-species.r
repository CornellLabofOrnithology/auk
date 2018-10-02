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
#' @param replace logical; multiple calls to `auk_species()` are additive, 
#'   unless `replace = FALSE`, in which case the previous list of species to 
#'   filter by will be removed and replaced by that in the current call.
#'   
#' @details The list species is checked against the eBird taxonomy for validity.
#'   If the `auk` package includes a copy of the eBird taxonomy; however, if the
#'   version of the taxonomy doesn't match the version of the EBD (as determined
#'   by the filename), then the eBird API will be queried to get the correct
#'   taxonomy version.
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
auk_species <- function(x, species, replace)  {
  UseMethod("auk_species")
}

#' @export
auk_species.auk_ebd <- function(x, species, replace = FALSE) {
  # checks
  assertthat::assert_that(
    is.character(species),
    assertthat::is.flag(replace)
  )
  version <- auk_ebd_version(x)$taxonomy_version
  if (is.na(version)) {
    message(
      paste0("EBD version cannot be determined from filename\n",
             "Using eBird taxonomy version included in package")
    )
    version <- auk_version()$taxonomy_version
  }
  species_clean <- ebird_species(species, type = "scientific",
                                 version = version)

  # check all species names are valid
  if (any(is.na(species_clean))) {
    stop(
      paste0("The following species were not found in the eBird taxonomy: \n\t",
             paste(species[is.na(species_clean)], collapse =", "))
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
