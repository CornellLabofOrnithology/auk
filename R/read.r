#' Read an EBD file
#'
#' Read an eBird Basic Dataset file using [data.table::fread()],
#' [readr::read_delim()], or [read.delim] depending on which packages are
#' installed. `read_ebd()` reads the EBD itself, while read_sampling()` reads a
#' sampling event data file.
#'
#' @param x filename or `auk_ebd` object with associated output
#'   files as created by [auk_filter()].
#' @param reader character; the function to use for reading the input file,
#'   options are `"fread"`, `"readr"`, or `"base"`, for [data.table::fread()],
#'   [readr::read_delim()], or [read.delim], respectively. This argument should
#'   typically be left empty to have the function choose the best reader based
#'   on the installed packages.
#' @param sep character; single character used to separate fields within a row.
#' @param unique logical; should duplicate grouped checklists be removed. If
#'   `unique = TRUE`, [auk_unique()] is called on the EBD before returning.
#' @param setclass `tbl`, `data.frame`, or `data.table`; optionally set
#'   additional classes to set on the output data. All return objects are
#'   data frames, but may additionally be `tbl` (for use with `dplyr`
#'   and the tidyverse) or `data.table` (for use with `data.table`). The default
#'   is to return a tibble.
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
#' @return A `data.frame` with additional class `tbl` unless `setclass` is used,
#'   in which case a standard `data.frame` or `data.table` can be returned. An
#'   additional column, `checklist_id`, is added to output files if
#'   `unique = TRUE`, that uniquely identifies the checklist from which the
#'   observation came. This field is equal to `sampling_event_identifier` for
#'   non-group checklists, and `group_identifier` for group checklists.
#' @export
#' @examples
#' ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   read_ebd()
#' # optionally return a plain data.frame
#' ebd_df <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   read_ebd(setclass = "data.frame")
read_ebd <- function(x, reader, sep, unique, setclass) {
  UseMethod("read_ebd")
}

#' @export
#' @describeIn read_ebd Filename of EBD.
read_ebd.character <- function(x, reader, sep = "\t", unique = TRUE,
                               setclass = c("tbl", "data.frame",
                                            "data.table")) {
  # checks
  assertthat::assert_that(
    assertthat::is.string(x),
    file.exists(x),
    missing(reader) || is.character(reader),
    assertthat::is.string(sep), nchar(sep) == 1, sep != " ")
  setclass <- match.arg(setclass)
  if (setclass == "data.table" &&
      !requireNamespace("data.table", quietly = TRUE)) {
    stop("data.table package must be installed to return a data.table.")
  }

  # pick reader
  if (missing(reader)) {
    reader <- NULL
  }
  reader <- choose_reader(reader)

  # get header
  header <- get_header(x, sep = sep)
  if (header[length(header)] == "") {
    header <- header[-length(header)]
  }

  # read using fread, read_delim, or read.delim
  col_types <- get_col_types(header, reader = reader)
  if (reader == "fread") {
    out <- data.table::fread(x, sep = sep, quote = "", na.strings = "",
                             colClasses = col_types)
    # convert columns to logical
    tf_cols <- c("ALL SPECIES REPORTED", "HAS MEDIA", "APPROVED", "REVIEWED")
    for (i in tf_cols) {
      if (i %in% names(out)) {
        out[[i]] <- as.logical(out[[i]])
      }
    }
    # convert date column
    if ("OBSERVATION DATE" %in% names(out)) {
      out[["OBSERVATION DATE"]] <- as.Date(out[["OBSERVATION DATE"]],
                                           format = "%Y-%m-%d")
    }
  } else if (reader == "readr") {
    out <- readr::read_delim(x, delim = sep, quote = "", na = "",
                             col_types = col_types)
    if ("spec" %in% names(attributes(out))) {
      attr(out, "spec") <- NULL
    }
  } else {
    out <- utils::read.delim(x, sep = sep, quote = "", na.strings = "",
                             stringsAsFactors = FALSE, colClasses = col_types)
    # convert columns to logical
    tf_cols <- c("ALL.SPECIES.REPORTED", "HAS.MEDIA", "APPROVED", "REVIEWED")
    for (i in tf_cols) {
      if (i %in% names(out)) {
        out[[i]] <- as.logical(out[[i]])
      }
    }
  }

  # remove possible blank final column
  blank <- grepl("^[xX][0-9]{2}$", names(out)[ncol(out)])
  if (blank) {
    out[ncol(out)] <- NULL
  }

  # names to snake case
  names(out) <- clean_names(names(out))

  # remove duplicate group checklists
  if (unique) {
    out <- auk_unique(out)
  }
  row.names(out) <- NULL
  set_class(out, setclass = setclass)
}

#' @export
#' @describeIn read_ebd `auk_ebd` object output from [auk_filter()]
read_ebd.auk_ebd <- function(x, reader, sep = "\t", unique = TRUE,
                             setclass = c("tbl", "data.frame", "data.table")) {
  setclass <- match.arg(setclass)
  if (is.null(x$output)) {
    stop("No output EBD file in this auk_ebd object, try calling auk_filter().")
  }
  read_ebd(x$output, reader = reader, sep = sep, unique = unique,
           setclass = setclass)
}

#' @rdname read_ebd
#' @export
#' @examples
#' # read a sampling event data file
#' x <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") %>%
#'   read_sampling()
read_sampling <- function(x, reader, sep, unique, setclass) {
  UseMethod("read_sampling")
}

#' @export
#' @describeIn read_ebd Filename of sampling event data file
read_sampling.character <- function(x, reader, sep = "\t", unique = TRUE,
                                    setclass = c("tbl", "data.frame",
                                                 "data.table")) {
  setclass <- match.arg(setclass)
  out <- read_ebd(x = x, reader = reader, sep = sep, unique = FALSE,
                  setclass = setclass)
  if (unique) {
    out <- auk_unique(out, checklists_only = TRUE)
  }
  return(out)
}

#' @export
#' @describeIn read_ebd `auk_ebd` object output from [auk_filter()]. Must have
#'   had a sampling event data file set in the original call to [auk_ebd()].
read_sampling.auk_ebd <- function(x, reader, sep = "\t", unique = TRUE,
                                  setclass = c("tbl", "data.frame",
                                               "data.table")) {
  setclass <- match.arg(setclass)
  if (is.null(x$output_sampling)) {
    stop("No output sampling event data file in this auk_ebd object.")
  }
  read_sampling(x$output_sampling, reader = reader, sep = sep, unique = unique,
                setclass = setclass)
}
