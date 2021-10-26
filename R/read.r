#' Read an EBD file
#'
#' Read an eBird Basic Dataset file using [readr::read_delim()]. `read_ebd()`
#' reads the EBD itself, while read_sampling()` reads a sampling event data
#' file.
#' 
#' @param x filename or `auk_ebd` object with associated output
#'   files as created by [auk_filter()].
#' @param sep character; single character used to separate fields within a row.
#' @param unique logical; should duplicate grouped checklists be removed. If
#'   `unique = TRUE`, [auk_unique()] is called on the EBD before returning.
#' @param rollup logical; should taxonomic rollup to species level be applied. 
#'   If `rollup = TRUE`, [auk_rollup()] is called on the EBD before returning. 
#'   Note that this process can be time consuming for large files, try turning 
#'   rollup off if reading is taking too long.
#'
#' @details  This functions performs the following processing steps:
#'
#' - Data types for columns are manually set based on column names used in the
#' February 2017 EBD. If variables are added or names are changed in later
#' releases, any new variables will have data types inferred by the import
#' function used.
#' - Variables names are converted to `snake_case`.
#' - Duplicate observations resulting from group checklists are removed using
#' [auk_unique()], unless `unique = FALSE`.
#'
#' @return A data frame of EBD observations. An additional column,
#'   `checklist_id`, is added to output files if `unique = TRUE`, that uniquely
#'   identifies the checklist from which the observation came. This field is
#'   equal to `sampling_event_identifier` for non-group checklists, and
#'   `group_identifier` for group checklists.
#' @export
#' @family import
#' @examples
#' f <- system.file("extdata/ebd-sample.txt", package = "auk")
#' read_ebd(f)
read_ebd <- function(x, sep = "\t", unique = TRUE, rollup = TRUE) {
  UseMethod("read_ebd")
}

#' @export
#' @describeIn read_ebd Filename of EBD.
read_ebd.character <- function(x, sep = "\t", unique = TRUE, 
                               rollup = TRUE) {
  # checks
  assertthat::assert_that(
    assertthat::is.string(x),
    file.exists(x),
    assertthat::is.string(sep), nchar(sep) == 1, sep != " ",
    length(readLines(x, 2)) > 1)
  
  # get header
  header <- get_header(x, sep = sep)

  # read using fread, read_delim, or read.delim
  col_types <- get_col_types(header)
  out <- readr::read_delim(x, delim = sep, quote = "", na = "",
                           col_types = col_types,
                           col_select = which(header != ""),
                           name_repair = "minimal")
  if ("spec" %in% names(attributes(out))) {
    attr(out, "spec") <- NULL
  }
  out <- dplyr::as_tibble(out)
  
  # names to snake case
  names(out) <- clean_names(names(out))
  
  # remove duplicate group checklists
  if (unique) {
    if (!"group_identifier" %in% names(out)) {
      stop("unique = TRUE used but group_identifier not found in data.")
    }
    out <- auk_unique(out)
  }
  # taxonomic rollup
  if (rollup) {
    if (!"scientific_name" %in% names(out)) {
      stop("rollup = TRUE used but scientific_name not found in data.")
    }
    out <- auk_rollup(out)
  }
  row.names(out) <- NULL
  dplyr::as_tibble(out)
}

#' @export
#' @describeIn read_ebd `auk_ebd` object output from [auk_filter()]
read_ebd.auk_ebd <- function(x, sep = "\t", unique = TRUE, 
                             rollup = TRUE) {
  if (is.null(x$output)) {
    stop("No output EBD file in this auk_ebd object, try calling auk_filter().")
  }
  read_ebd(x$output, sep = sep, unique = unique, 
           rollup = rollup)
}

#' @rdname read_ebd
#' @export
#' @examples
#' # read a sampling event data file
#' x <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") %>%
#'   read_sampling()
read_sampling <- function(x, sep = "\t", unique = TRUE) {
  UseMethod("read_sampling")
}

#' @export
#' @describeIn read_ebd Filename of sampling event data file
read_sampling.character <- function(x, sep = "\t", unique = TRUE) {
  out <- read_ebd(x = x, sep = sep, unique = FALSE, 
                  rollup = FALSE)
  if (unique) {
    out <- auk_unique(out, checklists_only = TRUE)
  }
  return(out)
}

#' @export
#' @describeIn read_ebd `auk_ebd` object output from [auk_filter()]. Must have
#'   had a sampling event data file set in the original call to [auk_ebd()].
read_sampling.auk_ebd <- function(x, sep = "\t", unique = TRUE) {
  if (is.null(x$output_sampling)) {
    stop("No output sampling event data file in this auk_ebd object.")
  }
  read_sampling(x$output_sampling, sep = sep, unique = unique)
}

#' @export
#' @describeIn read_ebd `auk_sampling` object output from [auk_filter()].
read_sampling.auk_sampling <- function(x, sep = "\t", unique = TRUE) {
  if (is.null(x$output)) {
    stop("No output sampling file in this auk_ebd object, ",
         "try calling auk_filter().")
  }
  read_sampling(x$output, sep = sep, unique = unique)
}
