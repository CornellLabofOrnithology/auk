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
#'   each group. In the output dataset, this field will be updated to have a 
#'   full list of the checklist IDs that went into this group checklist.
#' @param species_id character; the name of the column identifying species
#'   uniquely. This is required to ensure that removing duplicates is done
#'   independently for each species. Note that this will not treat sub-species
#'   independently and, if that behavior is desired, the user will have to
#'   generate a column uniquely identifying species and subspecies and pass that
#'   column's name to this argument.
#' @param observer_id character; the name of the column identifying the owner 
#'   of this instance of the group checklist. In the output dataset, the full 
#'   list of observer IDs will be stored (comma separated) in the new 
#'   `observer_id` field. The order of these IDs will match the order of the 
#'   comma separated checklist IDs.
#' @param checklists_only logical; whether the dataset provided only contains
#'   checklist information as with the sampling event data file. If this
#'   argument is `TRUE`, then the `species_id` argument is ignored and removing
#'   of duplicated records is done at the checklist level not the species level.
#'
#' @details This function chooses the checklist within in each that has the
#'   lowest value for the field specified by `checklist_id`. A new column is
#'   also created, `checklist_id`, whose value is the taken from the field
#'   specified in the `checklist_id` parameter for non-group checklists and from
#'   the field specified by the `group_id` parameter for grouped checklists.
#'   
#'   All the checklist and observer IDs for the checklists that comprise a given
#'   group checklist will be retained as a comma separated string ordered by 
#'   checklist ID.
#'
#' @return A data frame with unique observations, and an additional field,
#'   `checklist_id`, which is a combination of the sampling event and group IDs.
#' @export
#' @family pre
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
                       observer_id = "observer_id",
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
    assertthat::is.string(observer_id),
    observer_id %in% names(x),
    # all id columns should be character vectors
    is.character(x[[group_id]]),
    is.character(x[[checklist_id]]),
    is.character(x[[observer_id]]),
    checklists_only || is.character(x[[species_id]]))
  
  # return as is if already run
  if (isTRUE(attr(x, "unique"))) {
    return(x)
  }
  
  # convert empty string groud_id to NA
  x[[group_id]][x[[group_id]] == ""] <- NA_integer_
  
  # identify and separate non-group records
  grouped <- !is.na(x[[group_id]])
  x_grouped <- x[grouped, ]

  # sort by sampling event id
  x_grouped <- x_grouped[order(x_grouped[[checklist_id]]), ]

  # identify grouping variables
  if (checklists_only) {
    cols <- group_id
  } else {
    cols <- c(species_id, group_id)
  }
  
  # generate list of checklist and observer ids
  ids <- dplyr::select(x_grouped, 
                       dplyr::all_of(c(cols, checklist_id, observer_id)))
  ids <- dplyr::group_by_at(ids, cols)
  ids <- dplyr::arrange_at(ids, checklist_id)
  ids <- dplyr::summarize(ids, 
                          .cid = paste(.data[[checklist_id]], collapse = ","),
                          .oid = paste(.data[[observer_id]], collapse = ","))
  ids <- dplyr::ungroup(ids)
  
  # add the collapsed ids
  x_grouped <- dplyr::inner_join(x_grouped, ids, by = cols)
  x_grouped[[checklist_id]] <- x_grouped$.cid
  x_grouped[[observer_id]] <- x_grouped$.oid
  x_grouped$.cid <- NULL
  x_grouped$.oid <- NULL
  
  # remove duplicated records, ensuring different species treated independently
  x_grouped <- x_grouped[!duplicated(x_grouped[, cols]), ]

  # set id field
  x$checklist_id <- x[[checklist_id]]
  x_grouped$checklist_id <- x_grouped[[group_id]]

  # only keep non-group or non-duplicated records
  x <- rbind(x[!grouped, ], x_grouped)

  # move id field to front
  x <- dplyr::select(x, "checklist_id", dplyr::everything())

  # attribute flag
  attr(x, "unique") <- TRUE
  
  dplyr::as_tibble(x)
}
