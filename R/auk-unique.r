#' Remove duplicate group checklists
#'
#' eBird checklists can be shared among a group of multiple observers, in which
#' case observations will be duplicated in the database. This functions removes
#' these duplicates from the eBird Basic Dataset (EBD) or the EBD sampling event
#' data (with `checklists_only = TRUE`), creating a set of unique bird
#' observations. This function is called automatically by [read_ebd()] and
#' [read_sampling()].
#'
#' @param x data.frame; the EBD data frame, typically as imported by
#'   [read_ebd()].
#' @param group_id character; the name of the group ID column.
#' @param checklist_id character; the name of the checklist ID column, each
#'   checklist within a group will get a unique value for this field. The record
#'   with the lowest `checklist_id` will be picked as the unique record within
#'   each group.
#' @param species_id character; the name of the column identifying species
#'   uniquely. This is required to ensure that removing duplicates is done
#'   independently for each species. Note that this will not treat sub-species
#'   independently and, if that behavior is desired, the user will have to
#'   generate a column uniquely identifying species and subspecies and pass that
#'   column's name to this argument.
#' @param checklists_only logical; whether the dataset provided only contains
#'   checklist information as with the sampling event data file. If this
#'   argument is `TRUE`, then the `species_id` argument is ignored and removing
#'   of duplicated is done at the checklist level not the species level.
#'
#' @details This function chooses the checklist within in each that has the
#'   lowest value for the field specified by `checklist_id`. A new column is
#'   also created, `checklist_id`, whose value is the taken from the field
#'   specified in the `checklist_id` parameter for non-group checklists and from
#'   the field specified by the `group_id` parameter for grouped checklists.
#'
#' @return A data frame with unique observations, and an additional field,
#'   `checklist_id`, which is a combination of the sampling event and group IDs.
#' @export
#' @examples
#' # read in an ebd file and don't automatically remove duplicates
#' f <- system.file("extdata/ebd-sample.txt", package = "auk")
#' ebd <- read_ebd(f, unique = FALSE)
#' # remove duplicates
#' ebd_unique <- auk_unique(ebd)
#' nrow(ebd)
#' nrow(ebd_unique)
auk_unique <- function(x,
                       group_id = "group_identifier",
                       checklist_id = "sampling_event_identifier",
                       species_id = "scientific_name",
                       checklists_only = FALSE) {
  # checks
  assertthat::assert_that(
    is.data.frame(x),
    assertthat::is.flag(checklists_only),
    assertthat::is.string(group_id),
    group_id %in% names(x),
    assertthat::is.string(checklist_id),
    checklist_id %in% names(x),
    assertthat::is.string(species_id),
    checklists_only || species_id %in% names(x),
    # all id columns should be character vectors
    is.character(x[[group_id]]),
    is.character(x[[checklist_id]]),
    checklists_only || is.character(x[[species_id]]))
  
  # return as is if already run
  if (isTRUE(attr(x, "unique"))) {
    return(x)
  }

  # identify and separate non-group records
  grouped <- !is.na(x[[group_id]])
  x_grouped <- x[grouped, ]

  # sort by sampling event id
  x_grouped <- x_grouped[order(x_grouped[[checklist_id]]), ]

  # remove duplicated records, ensuring different species treated independently
  if (checklists_only) {
    cols <- group_id
  } else {
    cols <- c(species_id, group_id)
  }
  x_grouped <- x_grouped[!duplicated(x_grouped[, cols]), ]

  # set id field
  x$checklist_id <- x[[checklist_id]]
  x_grouped$checklist_id <- x_grouped[[group_id]]

  # only keep non-group or non-duplicated records
  x <- rbind(x[!grouped, ], x_grouped)

  # move id field to front
  x <- dplyr::select(x, .data$checklist_id, dplyr::everything())#out[, c("checklist_id", setdiff(names(out), "checklist_id"))]

  # attribute flag
  attr(x, "unique") <- TRUE
  
  dplyr::as_tibble(x)
}
