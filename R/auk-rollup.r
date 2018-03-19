#' Roll up eBird taxonomy to species
#' 
#' The eBird Basic Dataset (EBD) includes both true species and every other
#' field-identifiable taxon that could be relevant for birders to report. This 
#' includes taxa not identifiable to a species (e.g. hybrids) and taxa reported
#' below the species level (e.g. subspecies). This function produces a list of 
#' observations of true species, by removing the former and rolling the latter 
#' up to the species level. By default, [read_ebd()] calls `ebd_rollup()` when 
#' importing an eBird data file.
#'
#' @param x data.frame; data frame of eBird data, typically as imported by
#'   [read_ebd()]
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
#'   group of subspecies, e.g., Mallard (Mexican). If the checklist contains 
#'   multiple taxa corresponding to the same species, the lower level taxa are 
#'   rolled up, otherwise these records are left as is
#'   - **Form:** Miscellaneous other taxa, including recently-described species
#'   yet to be accepted or distinctive forms that are not universally accepted
#'   (Red-tailed Hawk (Northern), Upland Goose (Bar-breasted)). If the checklist
#'   contains multiple taxa corresponding to the same species, the lower level
#'   taxa are rolled up, otherwise these records are left as is.
#'   - **Spuh:**  Genus or identification at broad level -- e.g., duck sp.,
#'   dabbling duck sp.. Dropped by auk_rollup().
#'   - **Slash:** Identification to Species-pair e.g., American Black
#'   Duck/Mallard). Dropped by auk_rollup()
#'   - **Hybrid:** Hybrid between two species, e.g., American Black Duck x
#'   Mallard (hybrid). Dropped by auk_rollup()
#'   - **Intergrade:** Hybrid between two ISSF (subspecies or subspecies groups),
#'   e.g., Mallard (Mexican intergrade. Dropped by auk_rollup()
#'   - **Domestic:** Distinctly-plumaged domesticated varieties that may be
#'   free-flying (these do not count on personal lists) e.g., Mallard (Domestic
#'   type). Dropped by auk_rollup()
#'   
#' @return A data frame of the eBird data with taxonomic rollup applied.
#' @references Consult the [eBird taxonomy](http://help.ebird.org/customer/portal/articles/1006825-the-ebird-taxonomy)page for further details.
#' @export
#' @examples
#' # get the path to the example data included in the package
#' # in practice, provide path to ebd, e.g. f <- "data/ebd_relFeb-2018.txt
#' f <- system.file("extdata/ebd-rollup-ex.txt", package = "auk")
#' ebd <- read_ebd(f, rollup = FALSE)
#' nrow(ebd)
#' ebd_ru <- auk_rollup(ebd)
#' nrow(ebd_ru)
auk_rollup <- function(x) {
  assertthat::assert_that(
    is.data.frame(x),
    "scientific_name" %in% names(x)
  )
  
  # has auk_unique been applied?
  if ("checklist_id" %in% names(x)) {
    cid <- rlang::as_quosure(~ checklist_id)
  } else {
    cid <- rlang::as_quosure(~ sampling_event_identifier)
  }
  
  # remove anything not identifiable to a species
  tax <- dplyr::filter(auk::ebird_taxonomy, .data$category == "species")
  tax <- dplyr::select(tax, .data$scientific_name, .data$taxon_order)
  x <- dplyr::inner_join(x, tax, by = "scientific_name")
  
  # summarize species for cases where multiple subspecies reported on same list
  sp <- dplyr::select(x, rlang::UQ(cid), .data$scientific_name,
                      .data$observation_count)
  sp <- dplyr::mutate(sp, count = suppressWarnings(
    as.integer(.data$observation_count)))
  sp <- dplyr::group_by(sp, rlang::UQ(cid), .data$scientific_name)
  sp <- dplyr::summarise(sp, count = sum(.data$count))
  sp <- dplyr::ungroup(sp)
  sp <- dplyr::mutate(sp,
                      count = as.character(.data$count),
                      count = dplyr::coalesce(.data$count, "X"))
  
  # drop any duplicate species records
  x <- dplyr::group_by(x, rlang::UQ(cid), .data$scientific_name)
  # give precedence to true species records
  x <- dplyr::filter(x, dplyr::row_number(.data$taxon_order) == 1)
  x <- dplyr::ungroup(x)
  
  # update counts with summary
  x <- dplyr::inner_join(x, sp, by = c(as.character(cid)[2], "scientific_name"))
  x <- dplyr::mutate(x, observation_count = .data$count)
  x <- dplyr::select(x, -.data$count, -.data$taxon_order)
  dplyr::as_tibble(x)
}
