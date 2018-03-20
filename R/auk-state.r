#' Filter the eBird data by state
#'
#' Define a filter for the eBird Basic Dataset (EBD) based on a set of
#' states This function only defines the filter and, once all filters have
#' been defined, [auk_filter()] should be used to call AWK and perform the
#' filtering.
#'
#' @param x `auk_ebd` or `auk_sampling` object; reference to file created by 
#'   [auk_ebd()] or [auk_sampling()].
#' @param state character; states to filter by. eBird uses 4 to 6 character 
#'   state codes consisting of two parts, the 2-letter ISO country code and a 
#'   1-3 character state code, separated by a dash. For example, `"US-NY"` 
#'   corresponds to New York State in the United States. Refer to the data frame 
#'   [ebird_states] for look up state codes.
#' @param replace logical; multiple calls to `auk_state()` are additive,
#'   unless `replace = FALSE`, in which case the previous list of states to
#'   filter by will be removed and replaced by that in the current call.
#' 
#' @details It is not possible to filter by both country and state, so calling 
#' `auk_state()` will reset the country filter to all countries, and vice versa.
#' 
#' This function can also work with on an `auk_sampling` object if the user only 
#' wishes to filter the sampling event data.
#'
#' @return An `auk_ebd` object.
#' @export
#' @examples
#' # state codes for a given country can be looked up in ebird_states
#' dplyr::filter(ebird_states, country == "Costa Rica")
#' # choose texas, united states and puntarenas, cost rica
#' states <- c("US-TX", "CR-P")
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_state(states)
#'   
#' # alternatively, without pipes
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' auk_state(ebd, states)
auk_state <- function(x, state, replace = FALSE)  {
  UseMethod("auk_state")
}

#' @export
auk_state.auk_ebd <- function(x, state, replace = FALSE) {
  # checks
  assertthat::assert_that(
    is.character(state),
    assertthat::is.flag(replace)
  )
  state <- toupper(state)
  
  # check codes are valid
  valid_codes <- state %in% auk::ebird_states$state_code
  if (!all(valid_codes)) {
    m <- paste0("The following state codes are not valid: \n\t",
                paste(state[!valid_codes], collapse =", "))
    stop(m)
  }
  
  # add states to filter list
  if (replace) {
    x$filters$state <- state
  } else {
    x$filters$state <- c(x$filters$state, state)
  }
  x$filters$state <- sort(unique(x$filters$state))
  x$filters$country <- character()
  return(x)
}

#' @export
auk_state.auk_sampling <- function(x, state, replace = FALSE) {
  auk_state.auk_ebd(x, state, replace)
}