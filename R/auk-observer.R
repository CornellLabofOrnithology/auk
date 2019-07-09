#' Filter the eBird data by observer
#'
#' Define a filter for the eBird Basic Dataset (EBD) based on a set of
#' observer IDs This function only defines the filter and, once all filters have
#' been defined, [auk_filter()] should be used to call AWK and perform the
#' filtering.
#'
#' @param x `auk_ebd` or `auk_sampling` object; reference to file created by 
#'   [auk_ebd()] or [auk_sampling()].
#' @param observer_id character or integer; observers to filter by. Observer IDs
#'   can be provided either as integer (e.g. 12345) or character with the "obsr" 
#'   prefix as they appear in the EBD (e.g. "obsr12345").
#'
#' @return An `auk_ebd` or `auk_sampling`` object.
#' @export
#' @family filter
#' @examples
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_observer("obsr313215")
#'   
#' # alternatively, without pipes
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' auk_observer(ebd, observer = 313215)
auk_observer <- function(x, observer_id)  {
  UseMethod("auk_observer")
}

#' @export
auk_observer.auk_ebd <- function(x, observer_id) {
  if (is.character(observer_id)) {
    if (!all(stringr::str_detect(observer_id, "^obsr[0-9]+$"))) {
      stop("Invalid observer IDs detected, must be of form 'obsr12345'")
    }
  } else if (is_integer(observer_id)) {
    observer_id <- paste0("obsr", observer_id)
  } else {
    stop("observer_id must be a character or integer vector of valid IDs.")
  }
  observer_id <- tolower(observer_id)
  
  # add observer to filter list
  x$filters$observer <- observer_id
  return(x)
}

#' @export
auk_observer.auk_sampling <- function(x, observer_id) {
  auk_observer.auk_ebd(x, observer_id)
}