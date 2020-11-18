#' Get eBird taxonomy via the eBird API
#' 
#' Get the taxonomy used in eBird via the eBird API. 
#'
#' @param version integer; the version (i.e. year) of the taxonomy. The eBird 
#'   taxonomy is updated once a year in August. Leave this parameter blank to 
#'   get the current taxonomy.
#' @param locale character; the [locale for the common names](https://support.ebird.org/support/solutions/articles/48000804865-bird-names-in-ebird), 
#'   defaults to English.
#'
#' @return A data frame of all species in the eBird taxonomy, consisting of the 
#'   following columns:
#'   - `scientific_name`: scientific name.
#'   - `common_name`: common name, defaults to English, but different languages 
#'   can be selected using the `locale` parameter.
#'   - `species_code`: a unique alphanumeric code identifying each species.
#'   - `category`: whether the entry is for a species or another 
#'   field-identifiable taxon, such as `spuh`, `slash`, `hybrid`, etc.
#'   - `taxon_order`: numeric value used to sort rows in taxonomic order.
#'   - `order`: the scientific name of the order that the species belongs to.
#'   - `family`: the scientific name of the family that the species belongs to.
#'   - `report_as`: for taxa that can be resolved to true species (i.e. species,
#'   subspecies, and recognizable forms), this field links to the corresponding
#'   species code. For taxa that can't be resolved, this field is `NA`.
#' @export
#' @family helpers
#' @examples
#' \dontrun{
#' get_ebird_taxonomy()
#' }
get_ebird_taxonomy <- function(version, locale) {
  # prepare query
  url <- "https://ebird.org/ws2.0/ref/taxonomy/ebird"
  q <- list(fmt = "csv")
  if (!missing(version)) {
    stopifnot(is_integer(version), version >= 2015)
    q <- c(q, version = version)
  }
  if (!missing(locale)) {
    stopifnot(is.character(locale), length(locale) == 1)
    q <- c(q, locale = locale)
  }
  # query
  response <- httr::GET(url, query = q)
  httr::stop_for_status(response)
  # read to data frame
  tax <- readBin(response$content, "character")
  tax <- suppressWarnings(readr::read_csv(tax))
  names(tax) <- tolower(names(tax))
  # tidy up
  keep_names <- c("scientific_name", "common_name", "species_code", 
                  "category", "taxon_order",
                  "order", "family_sci_name", 
                  "report_as")
  keep_names <- intersect(keep_names, names(tax))
  if (length(keep_names) == 0) {
    stop("eBird taxonomy API cannont be accessed, visit https://ebird.org/ ",
         "to see if eBird is currently down.")
  }
  out <- dplyr::select(tax, dplyr::one_of(keep_names))
  names(out)[names(out) == "family_sci_name"] <- "family"
  out
}