#' Roll up eBird taxonomy to species
#' 
#' The eBird Basic Dataset (EBD) includes both true species and other taxa,  
#' including domestics, hybrids, subspecies, "spuhs", and recognizable forms. 
#' In some cases, a checklist may contain multiple records for the same species, 
#' for example, both Audubon and Myrtle Yellow-rumped Warblers, as well as some 
#' records that are not resolvable to species, for example, "warbler sp.". 
#' This function addresses these cases by removing taxa not identifiable to 
#' species and rolling up taxa identified below species level to a single record 
#' for each species in each checklist. By default, [read_ebd()] calls 
#' `ebd_rollup()` when importing an eBird data file.
#'
#' @param x data.frame; data frame of eBird data, typically as imported by
#'   [read_ebd()]
#' @details When rolling observations up to species level the observed counts
#'   are summed across any taxa that resolve to the same species. However, if
#'   any of these taxa have a count of "X" (i.e. the observer did not enter a
#'   count), then the rolled up record will get an "X" as well. For example, if 
#'   an observer saw 3 Myrtle and 2 Audubon Warblers, this will roll up to 5 
#'   Yellow-rumped Warblers. However, if an "X" was entered for Myrtle, this 
#'   would roll up to "X" for Yellow-rumped Warbler.
#' @return A data frame of the eBird data with taxonomic rollup applied.
#' @export
#' @examples
#' ebd <- system.file("extdata/ebd-rollup-ex.txt", package = "auk") %>% 
#'   read_ebd(rollup = FALSE)
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
  tax <- dplyr::select(tax, .data$scientific_name)
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
  x <- dplyr::filter(x, dplyr::row_number(.data$taxonomic_order) == 1)
  x <- dplyr::ungroup(x)
  
  # update counts with summary
  x <- dplyr::inner_join(x, sp, by = c(as.character(cid)[2], "scientific_name"))
  x <- dplyr::mutate(x, observation_count = .data$count)
  x <- dplyr::select(x, -.data$count)
  dplyr::as_tibble(x)
}
