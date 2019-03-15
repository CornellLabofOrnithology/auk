#' Filter the eBird file using AWK
#'
#' Convert the filters defined in an `auk_ebd` object into an AWK script and run
#' this script to produce a filtered eBird Reference Dataset (ERD). The initial
#' creation of the `auk_ebd` object should be done with [auk_ebd()] and filters
#' can be defined using the various other functions in this package, e.g.
#' [auk_species()] or [auk_country()]. **Note that this function typically takes
#' at least a couple hours to run on the full dataset**
#'
#' @param x `auk_ebd` or `auk_sampling` object; reference to file created by 
#'   [auk_ebd()] or [auk_sampling()].
#' @param file character; output file.
#' @param file_sampling character; optional output file for sampling data.
#' @param keep character; a character vector specifying the names of the columns
#'   to keep in the output file. Columns should be as they appear in the header
#'   of the EBD; however, names are not case sensitive and spaces may be
#'   replaced by underscores, e.g. `"COMMON NAME"`, `"common name"`, and
#'   `"common_NAME"` are all valid.
#' @param drop character; a character vector of columns to drop in the same
#'   format as `keep`. Ignored if `keep` is supplied.
#' @param awk_file character; output file to optionally save the awk script to.
#' @param sep character; the input field separator, the eBird file is tab
#'   separated by default. Must only be a single character and space delimited
#'   is not allowed since spaces appear in many of the fields.
#' @param filter_sampling logical; whether the sampling event data should also
#'   be filtered.
#' @param execute logical; whether to execute the awk script, or output it to a
#'   file for manual execution. If this flag is `FALSE`, `awk_file` must be
#'   provided.
#' @param overwrite logical; overwrite output file if it already exists
#' @param ... arguments passed on to methods.
#'
#' @details
#' If a sampling file is provided in the [auk_ebd][auk_ebd()] object, this
#' function will filter both the eBird Basic Dataset and the sampling data using
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
#' @family filter
#' @examples
#' # get the path to the example data included in the package
#' # in practice, provide path to ebd, e.g. f <- "data/ebd_relFeb-2018.txt"
#' f <- system.file("extdata/ebd-sample.txt", package = "auk")
#' # define filters
#' filters <- auk_ebd(f) %>%
#'   auk_species(species = c("Canada Jay", "Blue Jay")) %>%
#'   auk_country(country = c("US", "Canada")) %>%
#'   auk_bbox(bbox = c(-100, 37, -80, 52)) %>%
#'   auk_date(date = c("2012-01-01", "2012-12-31")) %>%
#'   auk_time(start_time = c("06:00", "09:00")) %>%
#'   auk_duration(duration = c(0, 60)) %>%
#'   auk_complete()
#'   
#' # alternatively, without pipes
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' filters <- auk_species(ebd, species = c("Canada Jay", "Blue Jay"))
#' filters <- auk_country(filters, country = c("US", "Canada"))
#' filters <- auk_bbox(filters, bbox = c(-100, 37, -80, 52))
#' filters <- auk_date(filters, date = c("2012-01-01", "2012-12-31"))
#' filters <- auk_time(filters, start_time = c("06:00", "09:00"))
#' filters <- auk_duration(filters, duration = c(0, 60))
#' filters <- auk_complete(filters)
#' 
#' # apply filters
#' \dontrun{
#' # output to a temp file for example
#' # in practice, provide path to output file
#' # e.g. f_out <- "output/ebd_filtered.txt"
#' f_out <- tempfile()
#' filtered <- auk_filter(filters, file = f_out)
#' str(read_ebd(filtered))
#' }
auk_filter <- function(x, file, ...) {
  UseMethod("auk_filter")
}

#' @export
#' @describeIn auk_filter `auk_ebd` object
auk_filter.auk_ebd <- function(x, file, file_sampling, keep, drop, awk_file,
                               sep = "\t", filter_sampling = TRUE, 
                               execute = TRUE, overwrite = FALSE, ...) {
  # checks
  awk_path <- auk_get_awk_path()
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
    missing(keep) || is.character(keep),
    missing(drop) || is.character(drop),
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
    if (!overwrite && file.exists(file) && execute) {
      stop("Output file already exists, use overwrite = TRUE.")
    }
    file <- normalizePath(file, winslash = "/", mustWork = FALSE)
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
    if (!overwrite && file.exists(file_sampling) && execute) {
      stop("Output sampling file already exists, use overwrite = TRUE.")
    }
    file_sampling <- normalizePath(file_sampling, winslash = "/", 
                                   mustWork = FALSE)
  }
  # zero-filling requires complete checklists
  if (filter_sampling && !x$filters$complete) {
    w <- paste("Sampling event data file provided, but filters have not been ",
               "set to only return complete checklists. Complete checklists ",
               "are required for zero-filling. You may want to use ",
               "auk_complete(), or manually filter out incomplete checklists.")
    warning(w)
  }
  
  # pick columns to retain
  must_keep <- c("group identifier", "sampling event identifier",
                 "observer id",
                 "scientific name", "observation count")
  if (!missing(keep)) {
    keep <- tolower(keep)
    keep <- stringr::str_replace_all(keep, "_", " ")
    stopifnot(all(keep %in% x$col_idx$name))
    if (!all(must_keep %in% keep)) {
      m <- paste("The following columns must be retained:",
                 paste(must_keep, collapse = ", "))
      stop(m)
    }
    idx <- x$col_idx$index[x$col_idx$name %in% keep]
    select_cols <- paste0("$", idx, collapse = ", ")
  } else if (!missing(drop)) {
    drop <- tolower(drop)
    drop <- stringr::str_replace_all(drop, "_", " ")
    drop <- stringr::str_replace_all(drop, "/", " ")
    stopifnot(all(drop %in% x$col_idx$name))
    if (any(must_keep %in% drop)) {
      m <- paste("The following columns must be retained:",
                 paste(must_keep, collapse = ", "))
      stop(m)
    }
    idx <- x$col_idx$index[!x$col_idx$name %in% drop]
    select_cols <- paste0("$", idx, collapse = ", ")
  } else {
    select_cols <- "$0"
  }

  # create awk script for the ebd
  awk_script <- awk_translate(filters = x$filters,
                              col_idx = x$col_idx,
                              sep = sep,
                              select = select_cols)
  # create awk script for the ebd sampling data
  if (filter_sampling) {
    # pick columns to retain
    if (!missing(keep)) {
      keep <- tolower(keep)
      keep <- stringr::str_replace_all(keep, "_", " ")
      idx <- x$col_idx_sampling$index[x$col_idx_sampling$name %in% keep]
      select_cols <- paste0("$", idx, collapse = ", ")
    } else if (!missing(drop)) {
      drop <- tolower(drop)
      drop <- stringr::str_replace_all(drop, "_", " ")
      idx <- x$col_idx_sampling$index[!x$col_idx_sampling$name %in% drop]
      select_cols <- paste0("$", idx, collapse = ", ")
    } else {
      select_cols <- "$0"
    }
    
    # remove species filter
    s_filters <- x$filters
    s_filters$species <- character()
    s_filters$breeding <- FALSE
    awk_script_sampling <- awk_translate(filters = s_filters,
                                         col_idx = x$col_idx_sampling,
                                         sep = sep,
                                         select = select_cols)
  }

  # output awk file
  if (!missing(awk_file)) {
    writeLines(awk_script, awk_file)
    if (!execute) {
      return(normalizePath(awk_file, winslash = "/", mustWork = FALSE))
    }
  }

  # run awk
  # ebd
  exit_code <- system2(awk_path,
                       args = paste0("'", awk_script, "' '", x$file, "'"),
                       stdout = file, stderr = FALSE)
  if (exit_code != 0) {
    stop("Error running AWK command.")
  } else {
    x$output <- normalizePath(file, winslash = "/")
  }

  # ebd sampling
  if (filter_sampling) {
    exit_code <- system2(awk_path,
                         args = paste0("'", awk_script_sampling, "' '",
                                       x$file_sampling, "'"),
                         stdout = file_sampling, stderr = FALSE)
    if (exit_code != 0) {
      stop("Error running AWK command.")
    } else {
      x$output_sampling <- normalizePath(file_sampling, winslash = "/")
    }
  }
  return(x)
}

#' @export
#' @describeIn auk_filter `auk_sampling` object
auk_filter.auk_sampling <- function(x, file, keep, drop, awk_file,
                                    sep = "\t", execute = TRUE, 
                                    overwrite = FALSE, ...) {
  # checks
  awk_path <- auk_get_awk_path()
  if (execute && is.na(awk_path)) {
    stop("auk_filter() requires a valid AWK install, unless execute = FALSE.")
  }
  assertthat::assert_that(
    file.exists(x$file),
    assertthat::is.flag(execute),
    !execute || assertthat::is.string(file),
    missing(awk_file) || assertthat::is.string(awk_file),
    assertthat::is.string(sep), nchar(sep) == 1, sep != " ",
    missing(keep) || is.character(keep),
    missing(drop) || is.character(drop),
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
    file <- normalizePath(file, winslash = "/", mustWork = FALSE)
  }
  # check output awk file
  if (!missing(awk_file) && !dir.exists(dirname(awk_file))) {
    stop("Output directory for awk file doesn't exist.")
  }
  
  # pick columns to retain
  must_keep <- c("group identifier", "sampling event identifier", "observer id")
  if (!missing(keep)) {
    keep <- tolower(keep)
    keep <- stringr::str_replace_all(keep, "_", " ")
    stopifnot(all(keep %in% x$col_idx$name))
    if (!all(must_keep %in% keep)) {
      m <- paste("The following columns must be retained:",
                 paste(must_keep, collapse = ", "))
      stop(m)
    }
    idx <- x$col_idx$index[x$col_idx$name %in% keep]
    select_cols <- paste0("$", idx, collapse = ", ")
  } else if (!missing(drop)) {
    drop <- tolower(drop)
    drop <- stringr::str_replace_all(drop, "_", " ")
    stopifnot(all(drop %in% x$col_idx$name))
    if (any(must_keep %in% drop)) {
      m <- paste("The following columns must be retained:",
                 paste(must_keep, collapse = ", "))
      stop(m)
    }
    idx <- x$col_idx$index[!x$col_idx$name %in% drop]
    select_cols <- paste0("$", idx, collapse = ", ")
  } else {
    select_cols <- "$0"
  }
  
  # create awk script for the sampling event file
  awk_script <- awk_translate(filters = x$filters,
                              col_idx = x$col_idx,
                              sep = sep,
                              select = select_cols)
  
  # output awk file
  if (!missing(awk_file)) {
    writeLines(awk_script, awk_file)
    if (!execute) {
      return(normalizePath(awk_file, winslash = "/"))
    }
  }
  
  # run awk
  # ebd
  exit_code <- system2(awk_path,
                       args = paste0("'", awk_script, "' '", x$file, "'"),
                       stdout = file, stderr = FALSE)
  if (exit_code != 0) {
    stop("Error running AWK command.")
  } else {
    x$output <- normalizePath(file, winslash = "/")
  }
  return(x)
}

awk_translate <- function(filters, col_idx, sep, select) {
  if (missing(select)) {
    select <- "$0"
  }
  # only keep filter columns
  col_idx <- col_idx[!is.na(col_idx$id), ]
  # set up filters
  filter_strings <- list(sep = sep, select = select)
  # species filter
  if (!"species" %in% names(filters) || length(filters$species) == 0) {
    filter_strings$species_array <- ""
    filter_strings$species <- ""
  } else {
    # generate list
    species_list <- paste(filters$species, collapse = "\t")
    species_array <- "
    split(\"%s\", speciesValues, \"\t\")
    for (i in speciesValues) species[speciesValues[i]] = 1"
    filter_strings$species_array <- sprintf(species_array, species_list)
    
    # check in list
    idx <- col_idx$index[col_idx$id == "species"]
    condition <- paste0("$", idx, " in species")
    filter_strings$species <- str_interp(awk_if, list(condition = condition))
  }
  # country filter
  if (length(filters$country) == 0) {
    filter_strings$country_array <- ""
    filter_strings$country <- ""
  } else {
    # generate list
    country_list <- paste(filters$country, collapse = "\t")
    country_array <- "
    split(\"%s\", countryValues, \"\t\")
    for (i in countryValues) countries[countryValues[i]] = 1"
    filter_strings$country_array <- sprintf(country_array, country_list)
    
    # check in list
    idx <- col_idx$index[col_idx$id == "country"]
    condition <- paste0("$", idx, " in countries")
    filter_strings$country <- str_interp(awk_if, list(condition = condition))
  }
  # state filter
  if (length(filters$state) == 0) {
    filter_strings$state_array <- ""
    filter_strings$state <- ""
  } else {
    # generate list
    state_list <- paste(filters$state, collapse = "\t")
    state_array <- "
    split(\"%s\", stateValues, \"\t\")
    for (i in stateValues) states[stateValues[i]] = 1"
    filter_strings$state_array <- sprintf(state_array, state_list)
    
    # check in list
    idx <- col_idx$index[col_idx$id == "state"]
    condition <- paste0("$", idx, " in states")
    filter_strings$state <- str_interp(awk_if, list(condition = condition))
  }
  # bcr filter
  if (length(filters$bcr) == 0) {
    filter_strings$bcr <- ""
  } else {
    idx <- col_idx$index[col_idx$id == "bcr"]
    condition <- paste0("$", idx, " == \"", filters$bcr, "\"",
                        collapse = " || ")
    filter_strings$bcr <- str_interp(awk_if, list(condition = condition))
  }
  # bbox filter
  if (length(filters$bbox) == 0) {
    filter_strings$bbox <- ""
  } else {
    lat_idx <- col_idx$index[col_idx$id == "lat"]
    lng_idx <- col_idx$index[col_idx$id == "lng"]
    condition <- paste0("$${lng_idx} >= ${xmn} && ",
                        "$${lng_idx} <= ${xmx} && ",
                        "$${lat_idx} >= ${ymn} && ",
                        "$${lat_idx} <= ${ymx}") %>%
      str_interp(list(lat_idx = lat_idx, lng_idx = lng_idx,
                      xmn = filters$bbox[1], xmx = filters$bbox[3],
                      ymn = filters$bbox[2], ymx = filters$bbox[4]))
    filter_strings$bbox <- str_interp(awk_if, list(condition = condition))
  }
  # date filter
  if (length(filters$date) == 0) {
    filter_strings$date_substr <- ""
    filter_strings$date <- ""
  } else if (isTRUE(attr(filters$date, "wildcard"))) {
    # extract just the month and day with awk
    idx <- col_idx$index[col_idx$id == "date"]
    filter_strings$date_substr <- sprintf("monthday = substr($%i, 6, 5)", idx)
    # remove the wildcard part of date
    dates <- stringr::str_replace(filters$date, "^\\*-", "")
    lo_wrap = if (attr(filters$date, "wrap")) "||" else "&&"
    condition <- str_interp("monthday >= \"${mn}\" ${lo} monthday <= \"${mx}\"",
                            list(mn = dates[1], mx = dates[2],
                                 lo = lo_wrap))
    filter_strings$date <- str_interp(awk_if, list(condition = condition))
  } else {
    filter_strings$date_substr <- ""
    idx <- col_idx$index[col_idx$id == "date"]
    condition <- str_interp("$${idx} >= \"${mn}\" && $${idx} <= \"${mx}\"",
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
    condition <- str_interp("$${idx} >= \"${mn}\" && $${idx} <= \"${mx}\"",
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
    condition <- str_interp("$${idx} >= \"${mn}\" && $${idx} <= \"${mx}\"",
                            list(idx = idx,
                                 mn = filters$last_edited[1],
                                 mx = filters$last_edited[2]))
    filter_strings$last_edited <- str_interp(awk_if,
                                             list(condition = condition))
  }
  # project filter
  if (length(filters$project) == 0) {
    filter_strings$project <- ""
  } else {
    idx <- col_idx$index[col_idx$id == "project"]
    condition <- paste0("$", idx, " == \"", filters$project, "\"",
                        collapse = " || ")
    filter_strings$project <- str_interp(awk_if, list(condition = condition))
  }
  # protocol filter
  if (length(filters$protocol) == 0) {
    filter_strings$protocol <- ""
  } else {
    idx <- col_idx$index[col_idx$id == "protocol"]
    condition <- paste0("$", idx, " == \"", filters$protocol, "\"",
                        collapse = " || ")
    filter_strings$protocol <- str_interp(awk_if, list(condition = condition))
  }
  # duration filter
  if (length(filters$duration) == 0) {
    filter_strings$duration <- ""
  } else {
    idx <- col_idx$index[col_idx$id == "duration"]
    condition <- str_interp("$${idx} >= ${mn} && $${idx} <= ${mx}",
                            list(idx = idx,
                                 mn = filters$duration[1],
                                 mx = filters$duration[2]))
    filter_strings$duration <- str_interp(awk_if, list(condition = condition))
  }
  # distance filter
  if (length(filters$distance) == 0) {
    filter_strings$distance <- ""
  } else {
    idx <- col_idx$index[col_idx$id == "distance"]
    # include stationary counts
    if (0.0001 >= filters$distance[1]) {
      p_idx <- col_idx$index[col_idx$id == "protocol"]
      inc_stat <- str_interp("$${idx} == \"Stationary\"",
                             list(idx = p_idx))
      condition <- str_interp(
        "${inc} || ($${idx} >= ${mn} && $${idx} <= ${mx})",
        list(idx = idx,
             mn = filters$distance[1],
             mx = filters$distance[2],
             inc = inc_stat))
    } else {
      condition <- str_interp("$${idx} >= ${mn} && $${idx} <= ${mx}",
                              list(idx = idx,
                                   mn = filters$distance[1],
                                   mx = filters$distance[2]))
    }
    filter_strings$distance <- str_interp(awk_if, list(condition = condition))
  }
  # breeding records only
  if ("breeding" %in% names(filters) && filters$breeding) {
    idx <- col_idx$index[col_idx$id == "breeding"]
    condition <- str_interp("$${idx} != \"\"", list(idx = idx))
    filter_strings$breeding <- str_interp(awk_if, list(condition = condition))
  } else {
    filter_strings$breeding <- ""
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
  FS = OFS = \"${sep}\"

  ${species_array}
  ${country_array}
  ${state_array}
}
{
  keep = 1

  # filters
  ${species}
  ${country}
  ${state}
  ${bcr}
  ${bbox}
  ${date_substr}
  ${date}
  ${time}
  ${last_edited}
  ${protocol}
  ${project}
  ${duration}
  ${distance}
  ${breeding}
  ${complete}

  # keeps header
  if (NR == 1) {
    keep = 1
  }

  if (keep == 1) {
    print ${select}
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
