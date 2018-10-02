#' Filter the eBird data by country
#'
#' Define a filter for the eBird Basic Dataset (EBD) based on a set of
#' countries. This function only defines the filter and, once all filters have
#' been defined, [auk_filter()] should be used to call AWK and perform the
#' filtering.
#'
#' @param x `auk_ebd` or `auk_sampling` object; reference to file created by 
#'   [auk_ebd()] or [auk_sampling()].
#' @param country character; countries to filter by. Countries can either be
#'   expressed as English names or
#'   [ISO 2-letter country codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2).
#'   English names are matched via regular expressions using
#'   [countrycode][countrycode()], so there is some flexibility in names.
#' @param replace logical; multiple calls to `auk_country()` are additive,
#'   unless `replace = FALSE`, in which case the previous list of countries to
#'   filter by will be removed and replaced by that in the current call.
#' 
#' @details This function can also work with on an `auk_sampling` object if the 
#'   user only wishes to filter the sampling event data.
#'
#' @return An `auk_ebd` object.
#' @export
#' @family filter
#' @examples
#' # country names and ISO2 codes can be mixed
#' # not case sensitive
#' country <- c("CA", "United States", "mexico")
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_country(country)
#'   
#' # alternatively, without pipes
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' auk_country(ebd, country)
auk_country <- function(x, country, replace = FALSE)  {
  UseMethod("auk_country")
}

#' @export
auk_country.auk_ebd <- function(x, country, replace = FALSE) {
  # checks
  assertthat::assert_that(
    is.character(country),
    assertthat::is.flag(replace)
  )

  # convert country names to codes
  name_codes <- countrycode::countrycode(country,
                                         origin = "country.name",
                                         destination = "iso2c",
                                         warn = FALSE)
  # lookup codes
  code_codes <- countrycode::countrycode(country,
                                         origin = "iso2c",
                                         destination = "iso2c",
                                         warn = FALSE)
  # combine, preference to codes
  country_codes <- dplyr::coalesce(code_codes, name_codes)
  
  # some codes don't match to countrycodes package, treat seperately
  no_code <- is.na(country_codes)
  country_codes[no_code] <- missing_countries(country[no_code])

  # check codes are valid
  valid_codes <- !is.na(country_codes)
  if (!all(valid_codes)) {
    m <- paste0("The following countries are not valid: \n\t",
                paste(country[!valid_codes], collapse =", "))
    stop(m)
  }

  # add countries to filter list
  if (replace) {
    x$filters$country <- country_codes
  } else {
    x$filters$country <- c(x$filters$country, country_codes)
  }
  x$filters$country <- sort(unique(x$filters$country))
  x$filters$state <- character()
  return(x)
}

#' @export
auk_country.auk_sampling <- function(x, country, replace = FALSE) {
  auk_country.auk_ebd(x, country, replace)
}

missing_countries <- function(x) {
  cc <- structure(c("AC", "CP", "CS", "XX", "XK", "FM"), 
                  .Names = c("ashmore and cartier islands", 
                             "clipperton island", 
                             "coral sea islands", "high seas", 
                             "kosovo", "micronesia"))
  # convert country names to codes
  name_codes <- cc[match(toupper(x), cc)]
  # lookup codes
  code_codes <- cc[tolower(x)]
  # combine, preference to codes
  out <- dplyr::coalesce(code_codes, name_codes)
  names(out) <- NULL
  out
}