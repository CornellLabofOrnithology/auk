#' Filter the eBird data by project code
#'
#' Some eBird records are collected as part of a particular project (e.g. the
#' Virginia Breeding Bird Survey) and have an associated project code in the
#' eBird dataset (e.g. EBIRD_ATL_VA). This function only defines the filter and,
#' once all filters have been defined, [auk_filter()] should be used to call AWK
#' and perform the filtering.
#'
#' @param x `auk_ebd` object; reference to object created by [auk_ebd()].
#' @param project character; project code to filter by (e.g. `"EBIRD_MEX"`).
#'   Multiple codes are accepted.
#'
#' @return An `auk_ebd` object.
#' @export
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
  
  # check all project names are valid
  bad_projects <- grepl("[^_A-Z]", project)
  if (any(bad_projects)) {
    stop(
      paste0("The following project names are not valid: \n\t",
             paste(project[bad_projects], collapse =", "))
    )
  }
  
  # set filter list
  x$filters$project <- project
  return(x)
}
