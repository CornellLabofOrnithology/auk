#' Filter the EBD using AWK
#'
#' Convert the filters defined in an `auk_ebd` object into an AWK script and run
#' this script to produce a filtered eBird Reference Dataset (ERD). The initial
#' creation of the `auk_ebd` object should be done with [auk_ebd()] and filters
#' can be defined using the various other functions in this package, e.g.
#' [auk_species()] or [auk_country()]. **Note that this function typically takes
#' at least a couple hours to run on the full EBD.**
#'
#' @param x `auk_ebd` object; reference to EBD file created by [auk_ebd()] with
#'   filters defined.
#' @param file character; output file.
#' @param file_sampling character; optional output file for EBD sampling data.
#' @param awk_file character; output file to optionally save the awk script to.
#' @param filter_sampling logical; whether the EBD sampling event data should
#'   also be filtered.
#' @param sep character; the input field separator, the EBD is tab separated by
#'   default. Must only be a single character and space delimited is not allowed
#'   since spaces appear in many of the fields.
#' @param execute logical; whether to execute the awk script, or output it to a
#'   file for manual execution. If this flag is `FALSE`, `awk_file` must be
#'   provided.
#' @param overwrite logical; overwrite output file if it already exists
#'
#' @details
#' If an EBD sampling file is provided in the [auk_ebd][auk_ebd()]
#' object, this function will filter both the EBD and the sampling data using
#' the same set of filters. This ensures that the files are in sync, i.e. that
#' they contain data on the same set of checklists.
#'
#' The AWK script can be saved for future reference by providing an output
#' filename to `awk_file`. The default behavior of this function is to generate
#' and run the AWK script, however, by setting `execute = FALSE` the AWK script
#' will be generated but not run. In this case, `file` is ignored and `awk_file`
#' must be specified.
#'
#' Calling this function requires that the command line utility AWK is
#' installed. Linux and Mac machines should have AWK by default, Windows users
#' will likely need to install [Cygwin](https://www.cygwin.com).
#'
#' @return An `auk_ebd` object with the output files set. If `execute = FALSE`,
#'   then the path to the AWK script is returned instead.
#' @export
#' @examples
#' # define filters
#' filters <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
#'   auk_ebd() %>%
#'   auk_species(species = c("Gray Jay", "Blue Jay")) %>%
#'   auk_country(country = c("US", "Canada")) %>%
#'   auk_extent(extent = c(-100, 37, -80, 52)) %>%
#'   auk_date(date = c("2012-01-01", "2012-12-31")) %>%
#'   auk_time(time = c("06:00", "09:00")) %>%
#'   auk_duration(duration = c(0, 60)) %>%
#'   auk_complete()
#' \dontrun{
#' # temp output file
#' out_file <- tempfile()
#' auk_filter(filters, file = out_file) %>%
#'   read_ebd() %>%
#'   str()
#' # clean
#' unlink(out_file)
#' }
auk_filter <- function(x, file, file_sampling, awk_file, sep,
                       filter_sampling, execute, overwrite) {
  UseMethod("auk_filter")
}

#' @export
auk_filter.auk_ebd <- function(x, file, file_sampling, awk_file, sep = "\t",
                               filter_sampling = TRUE, execute = TRUE,
                               overwrite = FALSE) {
  # checks
  awk_path <- auk_getpath()
  if (execute && is.na(awk_path)) {
    stop("auk_filter() requires a valid AWK install, unless execute = FALSE.")
  }
  assertthat::assert_that(
    file.exists(x$file),
    is.null(x$file_sampling) || file.exists(x$file_sampling),
    assertthat::is.flag(execute),
    !execute || assertthat::is.string(file),
    missing(awk_file) || assertthat::is.string(awk_file),
    assertthat::is.string(sep), nchar(sep) == 1, sep != " ",
    assertthat::is.flag(filter_sampling),
    assertthat::is.flag(overwrite)
  )
  if (!execute && missing(awk_file)) {
    stop("awk_file must be set when execute is FALSE.")
  }

  # check output file
  if (!missing(file)) {
    if (!dir.exists(dirname(file))) {
      stop("Output directory doesn't exist.")
    }
    if (!overwrite && file.exists(file)) {
      stop("Output file already exists, use overwrite = TRUE.")
    }
    file <- path.expand(file)
  }
  # check output awk file
  if (!missing(awk_file) && !dir.exists(dirname(awk_file))) {
    stop("Output directory for awk file doesn't exist.")
  }
  # check output sampling file
  if (is.null(x$file_sampling) || !execute || !filter_sampling) {
    filter_sampling <- FALSE
  }
  if (filter_sampling && missing(file_sampling)) {
    stop(paste0("An output file for the sampling data must be provided, ",
                "unless filter_sampling is FALSE."))
  } else if (filter_sampling) {
    if (!dir.exists(dirname(file_sampling))) {
      stop("Output directory for sampling file doesn't exist.")
    }
    if (!overwrite && file.exists(file_sampling)) {
      stop("Output sampling file already exists, use overwrite = TRUE.")
    }
    file_sampling <- path.expand(file_sampling)
  }
  # zero-filling requires complete checklists
  if (filter_sampling && !x$filters$complete) {
    w <- paste("Sampling event data file provided, but filters have not been ",
               "set to only return complete checklists. Complete checklists ",
               "are required for zero-filling. You may want to use ",
               "auk_complete(), or manually filter out incomplete checklists.")
    warning(w)
  }

  # create awk script for the ebd
  awk_script <- awk_translate(filters = x$filters,
                              col_idx = x$col_idx,
                              sep = sep)
  # create awk script for the ebd sampling data
  if (filter_sampling) {
    # remove species filter
    s_filters <- x$filters
    s_filters$species <- character()
    awk_script_sampling <- awk_translate(filters = s_filters,
                                         col_idx = x$col_idx_sampling,
                                         sep = sep)
  }

  # output awk file
  if (!missing(awk_file)) {
    writeLines(awk_script, awk_file)
    if (!execute) {
      return(normalizePath(awk_file))
    }
  }

  # run awk
  # ebd
  exit_code <- system2(awk_path,
                       args = paste0("'", awk_script, "' ", x$file),
                       stdout = file)
  if (exit_code != 0) {
    stop("Error running AWK command.")
  } else {
    x$output <- normalizePath(file)
  }

  # ebd sampling
  if (filter_sampling) {
    exit_code <- system2(awk_path,
                         args = paste0("'", awk_script_sampling, "' ",
                                       x$file_sampling),
                         stdout = file_sampling)
    if (exit_code != 0) {
      stop("Error running AWK command.")
    } else {
      x$output_sampling <- normalizePath(file_sampling)
    }
  }
  return(x)
}

awk_translate <- function(filters, col_idx, sep) {
  # set up filters
  filter_strings <- list(sep = sep)
  # species filter
  if (length(filters$species) == 0) {
    filter_strings$species <- ""
  } else {
    idx <- col_idx$index[col_idx$id == "species"]
    condition <- paste0("$", idx, " == \"", filters$species, "\"",
                        collapse = " || ")
    filter_strings$species <- str_interp(awk_if, list(condition = condition))
  }
  # country filter
  if (length(filters$country) == 0) {
    filter_strings$country <- ""
  } else {
    idx <- col_idx$index[col_idx$id == "country"]
    condition <- paste0("$", idx, " == \"", filters$country, "\"",
                        collapse = " || ")
    filter_strings$country <- str_interp(awk_if, list(condition = condition))
  }
  # extent filter
  if (length(filters$extent) == 0) {
    filter_strings$extent <- ""
  } else {
    lat_idx <- col_idx$index[col_idx$id == "lat"]
    lng_idx <- col_idx$index[col_idx$id == "lng"]
    condition <- paste0("$${lng_idx} > ${xmn} && ",
                        "$${lng_idx} < ${xmx} && ",
                        "$${lat_idx} > ${ymn} && ",
                        "$${lat_idx} < ${ymx}") %>%
      str_interp(list(lat_idx = lat_idx, lng_idx = lng_idx,
                      xmn = filters$extent[1], xmx = filters$extent[3],
                      ymn = filters$extent[2], ymx = filters$extent[4]))
    filter_strings$extent <- str_interp(awk_if, list(condition = condition))
  }
  # date filter
  if (length(filters$date) == 0) {
    filter_strings$date <- ""
  } else {
    idx <- col_idx$index[col_idx$id == "date"]
    condition <- str_interp("$${idx} > \"${mn}\" && $${idx} < \"${mx}\"",
                            list(idx = idx,
                                 mn = filters$date[1],
                                 mx = filters$date[2]))
    filter_strings$date <- str_interp(awk_if, list(condition = condition))
  }
  # time filter
  if (length(filters$time) == 0) {
    filter_strings$time <- ""
  } else {
    idx <- col_idx$index[col_idx$id == "time"]
    condition <- str_interp("$${idx} > \"${mn}\" && $${idx} < \"${mx}\"",
                            list(idx = idx,
                                 mn = filters$time[1],
                                 mx = filters$time[2]))
    filter_strings$time <- str_interp(awk_if, list(condition = condition))
  }
  # last edited date filter
  if (length(filters$last_edited) == 0) {
    filter_strings$last_edited <- ""
  } else {
    idx <- col_idx$index[col_idx$id == "last_edited"]
    condition <- str_interp("$${idx} > \"${mn}\" && $${idx} < \"${mx}\"",
                            list(idx = idx,
                                 mn = filters$last_edited[1],
                                 mx = filters$last_edited[2]))
    filter_strings$last_edited <- str_interp(awk_if,
                                             list(condition = condition))
  }
  # duration filter
  if (length(filters$duration) == 0) {
    filter_strings$duration <- ""
  } else {
    idx <- col_idx$index[col_idx$id == "duration"]
    condition <- str_interp("$${idx} > ${mn} && $${idx} < ${mx}",
                            list(idx = idx,
                                 mn = filters$duration[1],
                                 mx = filters$duration[2]))
    filter_strings$duration <- str_interp(awk_if, list(condition = condition))
  }
  # complete checklists only
  if (filters$complete) {
    idx <- col_idx$index[col_idx$id == "complete"]
    condition <- str_interp("$${idx} == 1", list(idx = idx))
    filter_strings$complete <- str_interp(awk_if, list(condition = condition))
  } else {
    filter_strings$complete <- ""
  }

  # generate awk script
  str_interp(awk_filter, filter_strings)
}

# awk script template
awk_filter <- "
BEGIN {
  FS = \"${sep}\"
  OFS = \"${sep}\"
}
{
  keep = 1

  # filters
  ${species}
  ${country}
  ${extent}
  ${date}
  ${time}
  ${duration}
  ${complete}

  # keeps header
  if (NR == 1) {
    keep = 1
  }

  if (keep == 1) {
    print $0
  }
}
"

awk_if <- "
  if (keep == 1 && (${condition})) {
    keep = 1
  } else {
    keep = 0
  }
"
