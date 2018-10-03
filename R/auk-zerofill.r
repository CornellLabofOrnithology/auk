#' Read and zero-fill an eBird data file
#'
#' Read an eBird Basic Dataset (EBD) file, and associated sampling event data
#' file, to produce a zero-filled, presence-absence dataset. The EBD contains
#' bird sightings and the sampling event data is a set of all checklists, they
#' can be combined to infer absence data by assuming any species not reported on
#' a checklist was had a count of zero.
#'
#' @param x filename, `data.frame` of eBird observations, or `auk_ebd` object
#'   with associated output files as created by [auk_filter()]. If a filename is
#'   provided, it must point to the EBD and the `sampling_events` argument must
#'   point to the sampling event data file. If a `data.frame` is provided it
#'   should have been imported with [read_ebd()], to ensure the variables names
#'   have been set correctly, and it must have been passed through
#'   [auk_unique()] to ensure duplicate group checklists have been removed.
#' @param sampling_events character or `data.frame`; filename for the sampling
#'   event data or a `data.frame` of the same data. If a `data.frame` is
#'   provided it should have been imported with [read_sampling()], to ensure the
#'   variables names have been set correctly, and it must have been passed
#'   through [auk_unique()] to ensure duplicate group checklists have been
#'   removed.
#' @param species character; species to include in zero-filled dataset, provided
#'   as scientific or English common names, or a mixture of both. These names
#'   must match the official eBird Taxomony ([ebird_taxonomy]). To include all
#'   species, leave this argument blank.
#' @param taxonomy_version integer; the version (i.e. year) of the taxonomy. In
#'   most cases, this should be left empty to use the version of the taxonomy
#'   included in the package. See [get_ebird_taxonomy()].
#' @param collapse logical; whether to call `collapse_zerofill()` to return a
#'   data frame rather than an `auk_zerofill` object.
#' @param unique logical; should [auk_unique()] be run on the input data if it
#'   hasn't already.
#' @param rollup logical; should [auk_rollup()] be run on the input data if it
#'   hasn't already.
#' @param drop_higher logical; whether to remove taxa above species during the 
#'   rollup process, e.g. "spuhs" like "duck sp.". See [auk_rollup()].
#' @param complete logical; if `TRUE` (the default) all checklists are required 
#'   to be complete prior to zero-filling.
#' @param sep character; single character used to separate fields within a row.
#' @param ... additional arguments passed to methods.
#'
#' @details
#' `auk_zerofill()` generates an `auk_zerofill` object consisting of a list with
#' elements `observations` and `sampling_events`. `observations` is a data frame
#' giving counts and binary presence/absence data for each species.
#' `sampling_events` is a data frame with checklist level information. The two
#' data frames can be connected via the `checklist_id` field. This format is
#' efficient for storage since the checklist columns are not duplicated for each
#' species, however, working with the data often requires joining the two data
#' frames together.
#'
#' To return a data frame, set `collapse = TRUE`. Alternatively,
#' `zerofill_collapse()` generates a data frame from an `auk_zerofill` object,
#' by joining the two data frames together to produce a single data frame in
#' which each row provides both checklist and species information for a
#' sighting.
#' 
#' The list of species is checked against the eBird taxonomy for validity. This
#' taxonomy is updated once a year in August. The `auk` package includes a copy
#' of the eBird taxonomy, current at the time of release; however, if the EBD
#' and `auk` versions are not aligned, you may need to explicitly specify which
#' version of the taxonomy to use, in which case the eBird API will be queried
#' to get the correct version of the taxonomy.
#'
#' @return By default, an `auk_zerofill` object, or a data frame if `collapse =
#'   TRUE`.
#' @export
#' @family import
#' @examples
#' # read and zero-fill the ebd data
#' f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
#' f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
#' auk_zerofill(x = f_ebd, sampling_events = f_smpl)
#'
#' # use the species argument to only include a subset of species
#' auk_zerofill(x = f_ebd, sampling_events = f_smpl,
#'              species = "Collared Kingfisher")
#'
#' # to return a data frame use collapse = TRUE
#' ebd_df <- auk_zerofill(x = f_ebd, sampling_events = f_smpl, collapse = TRUE)
auk_zerofill <- function(x, ...) {
  UseMethod("auk_zerofill")
}

#' @export
#' @describeIn auk_zerofill EBD data frame.
auk_zerofill.data.frame <- function(x, sampling_events, 
                                    species, taxonomy_version,
                                    collapse = FALSE, unique = TRUE, 
                                    rollup = TRUE, drop_higher = TRUE,
                                    complete = TRUE, ...) {
  # checks
  assertthat::assert_that(
    is.data.frame(sampling_events),
    missing(species) || is.character(species),
    assertthat::is.flag(unique))

  # process species names
  # first check for scientific names
  if (!missing(species)) {
    # convert common names to scientific
    species_clean <- ebird_species(species, taxonomy_version = taxonomy_version)
    # check all species names are valid
    if (any(is.na(species_clean))) {
      stop(
        paste0("The following species were not found in the eBird taxonomy:",
               "\n\t",
               paste(species[is.na(species_clean)], collapse =", "))
      )
    }
  }
  
  # check that we only have complete checklists
  if (!all(sampling_events$all_species_reported)) {
    e <- paste0("Some checklists in sampling event data are not complete.\n",
                "Complete checklists are required for zero-filling.\n",
                "Try calling auk_complete() when filtering.")
    if (complete) {
      stop(e)
    } else {
      warning(e)
    }
  }

  # check that auk_unique has been run
  if (!isTRUE(attr(x, "unique"))) {
    if (!unique){
      stop(paste(
        "The EBD doesn't appear to have been run through auk_unique().",
        "Set unique = TRUE."))
    } else {
      x <- auk_unique(x)
    }
  }
  if (!isTRUE(attr(sampling_events, "unique"))) {
    if (!unique){
      stop(paste("The sampling events data doesn't appear to have been run",
                 "through auk_unique(). Set unique = TRUE."))
    } else {
      sampling_events <- auk_unique(sampling_events, checklists_only = TRUE)
    }
  }
  
  # check that auk_rollup has been run
  if (rollup && !isTRUE(attr(x, "rollup"))) {
    x <- auk_rollup(x, drop_higher = drop_higher)
  }

  # subset ebd to remove checklist level fields
  species_cols <- c("checklist_id", "scientific_name", "observation_count")
  if (any(!species_cols %in% names(x))) {
    stop(
      paste0("The following fields must appear in the EBD: \n\t",
             paste(species_cols, collapse =", "))
    )
  }
  x <- dplyr::select(x, dplyr::one_of(species_cols))

  # ensure all checklist in ebd are in sampling file
  if (!all(x$checklist_id %in% sampling_events$checklist_id)) {
    stop("Some checklists in EBD are missing from sampling event data.")
  }

  # subset ebd by species
  if (!missing(species)) {
    in_ebd <- (species_clean %in% x$scientific_name)
    if (all(!in_ebd)) {
      stop("None of the provided species appear in the EBD.")
    } else if (any(!in_ebd)) {
      warning(
        paste0("The following species were not found in the EBD: \n\t",
               paste(species[!in_ebd], collapse =", "))
      )
    }
    species_clean <- species_clean[in_ebd]
    x <- x[x$scientific_name %in% species_clean, ]
  }

  # add presence absence column
  x$species_observed <- x$observation_count
  x$species_observed[x$species_observed == "X"] <- "1"
  x$species_observed <- (as.numeric(x$species_observed) >= 1)

  # remove absences that may have sneaked through
  # there shouldn't be any of these, but just in case...
  x <- x[x$species_observed == 1, ]

  # fill in implicit missing values
  x <- tidyr::complete_(
    x,
    cols = list(checklist_id = ~ sampling_events$checklist_id,
                "scientific_name"),
    fill = list(observation_count = "0", species_observed = FALSE)
  )

  out <- structure(
    list(observations = dplyr::as_tibble(x),
         sampling_events = dplyr::as_tibble(sampling_events)),
    class = "auk_zerofill"
  )
  # return a data frame?
  if (collapse) {
    return(collapse_zerofill(out))
  } else {
    return(out)
  }
}

#' @export
#' @describeIn auk_zerofill Filename of EBD.
auk_zerofill.character <- function(x, sampling_events, 
                                   species, taxonomy_version,
                                   collapse = FALSE, unique = TRUE, 
                                   rollup = TRUE,  drop_higher = TRUE,
                                   complete = TRUE, sep = "\t", ...) {
  # checks
  assertthat::assert_that(
    assertthat::is.string(x), file.exists(x),
    assertthat::is.string(sampling_events), file.exists(sampling_events),
    missing(species) || is.character(species),
    assertthat::is.string(sep), nchar(sep) == 1, sep != " ")

  # read in the two files
  ebd <- read_ebd(x = x, sep = sep, unique = FALSE, rollup = FALSE)
  sed <- read_sampling(x = sampling_events, sep = sep, unique = FALSE)

  # pass on to df method
  auk_zerofill(x = ebd, sampling_events = sed, species = species, 
               collapse = collapse, unique = unique, complete = complete,
               rollup = rollup)
}

#' @export
#' @describeIn auk_zerofill `auk_ebd` object output from [auk_filter()]. Must
#'   have had a sampling event data file set in the original call to
#'   [auk_ebd()].
auk_zerofill.auk_ebd <- function(x, species, taxonomy_version,
                                 collapse = FALSE, unique = TRUE, 
                                 rollup = TRUE,  drop_higher = TRUE,
                                 complete = TRUE, sep = "\t", ...) {
  # check that output files defined
  if (is.null(x$output)) {
    stop("No output EBD file in this auk_ebd object, try calling auk_filter().")
  }
  if (is.null(x$output_sampling)) {
    stop("No output sampling event data file in this auk_ebd object.")
  }

  # pass on to file method
  auk_zerofill(x = x$output, sampling_events = x$output_sampling,
               species = species, collapse = collapse, 
               unique = unique, complete = complete, rollup = rollup,
               sep = sep)
}

#' @rdname auk_zerofill
#' @export
collapse_zerofill <- function(x) {
  UseMethod("collapse_zerofill")
}

#' @export
collapse_zerofill.auk_zerofill <- function(x) {
  out <- dplyr::inner_join(x$sampling_events, x$observations, 
                           by = "checklist_id")
  dplyr::as_tibble(out)
}

#' @export
print.auk_zerofill <- function(x, ...) {
  checklists <- nrow(x$sampling_events)
  species <- length(unique(x$observations$scientific_name))
  cat(
    paste0(
      "Zero-filled EBD: ",
      format(checklists, big.mark = ","), " unique checklists, ",
      "for ", format(species, big.mark = ","), " species.\n"
    )
  )
}
