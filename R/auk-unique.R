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
#' @param effort_cols character; checklist-level columns to check for
#'   disagreement among group members, used to populate the
#'   `effort_disagreement` column described in Details. Columns not present
#'   in `x` (e.g. because of `keep`/`drop` in [auk_filter()]) are ignored.
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
#'   Within a shared checklist, every species reported by *any* member of the
#'   group is retained in the output, not just those reported by the member
#'   with the lowest `checklist_id`. The deduplication key is the combination
#'   of `species_id` and `group_id`, so a record is only dropped as a
#'   duplicate if another member of the same group reported that exact same
#'   species.
#'
#'   Checklist-level fields that aren't part of this deduplication key (e.g.
#'   observed duration, distance travelled, protocol, or whether all species
#'   were reported) are **not** combined or reconciled across group members:
#'   the value from the member with the lowest `checklist_id` is kept, and
#'   values from other members are discarded, even if they disagree. The
#'   output's `effort_disagreement` column flags groups where this happened,
#'   i.e. where members disagreed (ignoring `NA`s) on any of the columns
#'   named in `effort_cols`; it's always `FALSE` for checklists that aren't
#'   part of a group.
#'
#' @return A data frame with unique observations, and two additional fields:
#'   `checklist_id`, a combination of the sampling event and group IDs, and
#'   `effort_disagreement`, a logical field described in Details.
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
#' # shared checklists whose members disagreed on effort fields like
#' # duration, distance, protocol, or completeness are flagged
#' "effort_disagreement" %in% names(ebd_unique)
auk_unique <- function(
  x,
  group_id = "group_identifier",
  checklist_id = "sampling_event_identifier",
  species_id = "scientific_name",
  observer_id = "observer_id",
  checklists_only = FALSE,
  effort_cols = c(
    "duration_minutes",
    "effort_distance_km",
    "protocol_type",
    "all_species_reported"
  )
) {
  # checks
  assertthat::assert_that(
    is.data.frame(x),
    assertthat::is.flag(checklists_only),
    is.character(effort_cols),
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
    checklists_only || is.character(x[[species_id]])
  )

  # return as is if already run
  if (isTRUE(attr(x, "unique"))) {
    return(x)
  }

  # convert empty string group_id to NA
  x[[group_id]][x[[group_id]] == ""] <- NA_character_

  # identify and separate non-group records
  grouped <- !is.na(x[[group_id]])
  x_grouped <- x[grouped, ]

  # identify grouping variables
  if (checklists_only) {
    cols <- group_id
    group_key <- x_grouped[[group_id]]
  } else {
    cols <- c(species_id, group_id)
    group_key <- paste(
      x_grouped[[species_id]],
      x_grouped[[group_id]],
      sep = "\r"
    )
  }

  # columns to check for effort disagreement within a group
  disagreement_cols <- intersect(effort_cols, names(x_grouped))

  # row indices of the records making up each group. this groups the data
  # without an expensive full-table sort, and avoids running a separate
  # dplyr group_by()/summarize() pass (slow for the large numbers of small
  # groups typical of shared checklists) in favor of operating directly on
  # the relevant id columns within each group
  group_rows <- split(seq_len(nrow(x_grouped)), group_key, drop = TRUE)
  cid_vec <- x_grouped[[checklist_id]]
  oid_vec <- x_grouped[[observer_id]]

  # for each group: the row with the lowest checklist_id (the record whose
  # other fields are kept), and the comma separated, checklist_id-ordered
  # lists of checklist and observer ids
  rep_row <- integer(length(group_rows))
  checklist_ids <- character(length(group_rows))
  observer_ids <- character(length(group_rows))
  for (i in seq_along(group_rows)) {
    rows <- group_rows[[i]]
    rows <- rows[order(cid_vec[rows])]
    rep_row[i] <- rows[1]
    checklist_ids[i] <- paste(cid_vec[rows], collapse = ",")
    observer_ids[i] <- paste(oid_vec[rows], collapse = ",")
  }

  # flag groups whose members disagree (ignoring NAs) on any effort column
  effort_disagreement <- logical(length(group_rows))
  for (col in disagreement_cols) {
    col_vec <- x_grouped[[col]]
    disagree <- vapply(
      group_rows,
      function(rows) {
        vals <- col_vec[rows]
        length(unique(vals[!is.na(vals)])) > 1
      },
      logical(1)
    )
    effort_disagreement <- effort_disagreement | disagree
  }

  # reduce to one record per group, keeping the lowest checklist_id record,
  # and attach the collapsed ids and disagreement flag
  x_grouped <- x_grouped[rep_row, ]
  x_grouped[[checklist_id]] <- checklist_ids
  x_grouped[[observer_id]] <- observer_ids
  x_grouped$effort_disagreement <- effort_disagreement

  # set id field
  x$checklist_id <- x[[checklist_id]]
  x_grouped$checklist_id <- x_grouped[[group_id]]

  # non-group checklists can't have effort disagreement
  x$effort_disagreement <- FALSE

  # only keep non-group or non-duplicated records
  x <- rbind(x[!grouped, ], x_grouped)

  # move id field to front
  x <- dplyr::select(x, "checklist_id", dplyr::everything())

  # attribute flag
  attr(x, "unique") <- TRUE

  return(dplyr::as_tibble(x))
}
