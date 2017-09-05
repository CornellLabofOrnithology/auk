#' Filter the eBird data by country
#'
#' Define a filter for the eBird Basic Dataset (EBD) based on a set of
#' countries. This function only defines the filter and, once all filters have
#' been defined, [auk_filter()] should be used to call AWK and perform the
#' filtering.
#'
#' @param x `auk_ebd` object; reference to EBD file created by [auk_ebd()].
#' @param country character; countries to filter by. Countries can either be
#'   expressed as English names or
#'   [ISO 2-letter country codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2).
#'   English names are matched via regular expressions using
#'   [countrycode][countrycode()], so there is some flexibility in names.
#' @param replace logical; multiple calls to `auk_country()` are additive,
#'   unless `replace = FALSE`, in which case the previous list of countries to
#'   filter by will be removed and replaced by that in the current call.
#'
#' @return An `auk_ebd` object.
#' @export
#' @examples
#' # country names and ISO2 codes can be mixed
#' # not case sensitive
#' country <- c("CA", "United States", "mexico")
#' system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_country(country)
auk_country <- function(x, country, replace)  {
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
  code_codes <- match(tolower(country),
                      tolower(countrycode::countrycode_data$iso2c))
  code_codes <- countrycode::countrycode_data$iso2c[code_codes]
  # combine, preference to codes
  country_codes <- ifelse(is.na(code_codes), name_codes, code_codes)

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
  x$filters$country <- sort(unique(c(x$filters$country, country_codes)))
  return(x)
}
