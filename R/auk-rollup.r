#' Roll up eBird taxonomy to species
#' 
#' The eBird Basic Dataset (EBD) includes both true species and every other
#' field-identifiable taxon that could be relevant for birders to report. This 
#' includes taxa not identifiable to a species (e.g. hybrids) and taxa reported
#' below the species level (e.g. subspecies). This function produces a list of 
#' observations of true species, by removing the former and rolling the latter 
#' up to the species level. In the resulting EBD data.frame, 
#' `category` will be `"species"` for all records and the subspecies fields will 
#' be dropped. By default, [read_ebd()] calls `ebd_rollup()` when importing an 
#' eBird data file.
#'
#' @param x data.frame; data frame of eBird data, typically as imported by
#'   [read_ebd()]
#' @param taxonomy_version integer; the version (i.e. year) of the taxonomy. In
#'   most cases, this should be left empty to use the version of the taxonomy
#'   included in the package. See [get_ebird_taxonomy()].
#' @param drop_higher logical; whether to remove taxa above species during the 
#'   rollup process, e.g. "spuhs" like "duck sp.".
#'   
#' @details When rolling observations up to species level the observed counts
#'   are summed across any taxa that resolve to the same species. However, if
#'   any of these taxa have a count of "X" (i.e. the observer did not enter a
#'   count), then the rolled up record will get an "X" as well. For example, if 
#'   an observer saw 3 Myrtle and 2 Audubon's Warblers, this will roll up to 5 
#'   Yellow-rumped Warblers. However, if an "X" was entered for Myrtle, this 
#'   would roll up to "X" for Yellow-rumped Warbler.
#'   
#'   The eBird taxonomy groups taxa into eight different categories. These 
#'   categories, and the way they are treated by [auk_rollup()] are as follows:
#'   
#'   - **Species:** e.g., Mallard. Combined with lower level taxa if present on 
#'   the same checklist.
#'   - **ISSF or Identifiable Sub-specific Group:** Identifiable subspecies or
#'   group of subspecies, e.g., Mallard (Mexican). Rolled-up to species level.
#'   - **Intergrade:** Hybrid between two ISSF (subspecies or subspecies
#'   groups), e.g., Mallard (Mexican intergrade. Rolled-up to species level.
#'   - **Form:** Miscellaneous other taxa, including recently-described species
#'   yet to be accepted or distinctive forms that are not universally accepted
#'   (Red-tailed Hawk (Northern), Upland Goose (Bar-breasted)). If the checklist
#'   contains multiple taxa corresponding to the same species, the lower level
#'   taxa are rolled up, otherwise these records are left as is.
#'   - **Spuh:**  Genus or identification at broad level -- e.g., duck sp.,
#'   dabbling duck sp.. Dropped by `auk_rollup()`.
#'   - **Slash:** Identification to Species-pair e.g., American Black
#'   Duck/Mallard). Dropped by `auk_rollup()`.
#'   - **Hybrid:** Hybrid between two species, e.g., American Black Duck x
#'   Mallard (hybrid). Dropped by `auk_rollup()`.
#'   - **Domestic:** Distinctly-plumaged domesticated varieties that may be
#'   free-flying (these do not count on personal lists) e.g., Mallard (Domestic
#'   type). Dropped by `auk_rollup()`.
#'   
#'   The rollup process is based on the eBird taxonomy, which is updated once a
#'   year in August. The `auk` package includes a copy of the eBird taxonomy,
#'   current at the time of release; however, if the EBD and `auk` versions are
#'   not aligned, you may need to explicitly specify which version of the
#'   taxonomy to use, in which case the eBird API will be queried to get the
#'   correct version of the taxonomy.
#'   
#' @return A data frame of the eBird data with taxonomic rollup applied.
#' @references Consult the [eBird taxonomy](https://ebird.org/science/use-ebird-data/the-ebird-taxonomy) 
#'   page for further details.
#' @export
#' @family pre
#' @examples
#' # get the path to the example data included in the package
#' # in practice, provide path to ebd, e.g. f <- "data/ebd_relFeb-2018.txt
#' f <- system.file("extdata/ebd-rollup-ex.txt", package = "auk")
#' # read in data without rolling up
#' ebd <- read_ebd(f, rollup = FALSE)
#' # rollup
#' ebd_ru <- auk_rollup(ebd)
#' # keep higher taxa
#' ebd_higher <- auk_rollup(ebd, drop_higher = FALSE)
#' 
#' # all taxa not identifiable to species are dropped
#' unique(ebd$category)
#' unique(ebd_ru$category)
#' unique(ebd_higher$category)
#' 
#' # yellow-rump warbler subspecies rollup
#' library(dplyr)
#' # without rollup, there are three observations
#' ebd %>%
#'   filter(common_name == "Yellow-rumped Warbler") %>% 
#'   select(checklist_id, category, common_name, subspecies_common_name, 
#'          observation_count)
#' # with rollup, they have been combined
#' ebd_ru %>%
#'   filter(common_name == "Yellow-rumped Warbler") %>% 
#'   select(checklist_id, category, common_name, observation_count)
auk_rollup <- function(x, taxonomy_version, drop_higher = TRUE) {
  assertthat::assert_that(
    is.data.frame(x),
    "scientific_name" %in% names(x)
  )
  
  # return as is if already run
  if (isTRUE(attr(x, "rollup"))) {
    return(x)
  }
  
  # has auk_unique been applied?
  if ("checklist_id" %in% names(x)) {
    cid <- rlang::as_quosure(~ checklist_id)
  } else {
    cid <- rlang::as_quosure(~ sampling_event_identifier)
  }
  
  # get the correct ebird taxonomy version
  if (missing(taxonomy_version) || 
      taxonomy_version == auk_version()$taxonomy_version) {
    tax <- auk::ebird_taxonomy
  } else {
    stopifnot(is_integer(taxonomy_version), length(taxonomy_version) == 1)
    tax <- get_ebird_taxonomy(version = taxonomy_version)
  }
  
  # remove anything not identifiable to a species
  if (drop_higher) {
    include <- "species"
  } else {
    include <- c("species", "slash", "spuh", "hybrid")
  }
  # include forms that don't roll up to a species
  # these are mostly undescribed species
  undesc <- dplyr::filter(tax, .data$category == "form", is.na(.data$report_as))
  tax <- dplyr::filter(tax, .data$category %in% include)
  tax <- rbind(tax, undesc)
  tax <- dplyr::select(tax, "scientific_name", "taxon_order")
  x <- dplyr::inner_join(x, tax, by = "scientific_name")
  
  if (nrow(x) == 0) {
    if ("subspecies_common_name" %in% names(x)) {
      x$subspecies_common_name <- NULL
    }
    if ("subspecies_scientific_name" %in% names(x)) {
      x$subspecies_scientific_name <- NULL
    }
    attr(x, "rollup") <- TRUE
    return(dplyr::as_tibble(x))
  }
  
  # summarize species for cases where multiple subspecies reported on same list
  sp <- dplyr::select(x, !!cid, "scientific_name", "observation_count")
  sp <- dplyr::mutate(sp, count = suppressWarnings(
    as.integer(.data$observation_count)))
  sp <- dplyr::group_by(sp, !!cid, .data$scientific_name)
  sp <- dplyr::summarise(sp, count = sum(.data$count))
  sp <- dplyr::ungroup(sp)
  sp <- dplyr::mutate(sp,
                      count = as.character(.data$count),
                      count = dplyr::coalesce(.data$count, "X"))
  
  # drop any duplicate species records
  x <- dplyr::group_by(x, !!cid, .data$scientific_name)
  # give precedence to true species records
  x <- dplyr::filter(x, dplyr::row_number(.data$taxon_order) == 1)
  x <- dplyr::ungroup(x)
  
  # update counts with summary
  x <- dplyr::inner_join(x, sp, by = c(rlang::quo_text(cid), "scientific_name"))
  x <- dplyr::mutate(x, observation_count = .data$count)
  x <- dplyr::select(x, -"count", -"taxon_order")
  
  # drop subspecies fields, set category to species
  if ("category" %in% names(x)) {
    x$category <- ifelse(x$category %in% include, x$category, "species")
  }
  if ("subspecies_common_name" %in% names(x)) {
    x$subspecies_common_name <- NULL
  }
  if ("subspecies_scientific_name" %in% names(x)) {
    x$subspecies_scientific_name <- NULL
  }
  
  # attribute flag
  attr(x, "rollup") <- TRUE
  dplyr::as_tibble(x)
}
