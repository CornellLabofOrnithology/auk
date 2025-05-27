#' Filter the eBird data by project code
#'
#' Some eBird records are collected as part of a particular project (e.g. the
#' Virginia Breeding Bird Survey) and have an associated project code in the
#' eBird dataset (e.g. EBIRD_ATL_VA). This function only defines the filter and,
#' once all filters have been defined, [auk_filter()] should be used to call AWK
#' and perform the filtering.
#'
#' @param x `auk_ebd` or `auk_sampling` object; reference to file created by 
#'   [auk_ebd()] or [auk_sampling()].
#' @param project character; project code to filter by (e.g. `"EBIRD_MEX"`).
#'   Multiple codes are accepted.
#' 
#' @details This function can also work with on an `auk_sampling` object if the 
#'   user only wishes to filter the sampling event data.
#'
#' @return An `auk_ebd` object.
#' @export
#' @family filter
#' @examples
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_project("EBIRD_MEX")
#'   
#' # alternatively, without pipes
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' auk_project(ebd, "EBIRD_MEX")
auk_project <- function(x, project)  {
  UseMethod("auk_project")
}

#' @export
auk_project.auk_ebd <- function(x, project) {
  # checks
  assertthat::assert_that(
    is.character(project),
    all(nchar(project) > 0)
  )
  
  # check for project column
  if (!"project" %in% x$col_idx$id) {
    stop("Project column missing from EBD")
  }
  if (!is.null(x$col_idx_sampling) && !"project" %in% x$col_idx_sampling$id) {
    stop("Project column missing from sampling event data")
  }
  
  # set filter list
  x$filters$project <- project
  return(x)
}

#' @export
auk_project.auk_sampling <- function(x, project) {
  auk_project.auk_ebd(x, project)
}
