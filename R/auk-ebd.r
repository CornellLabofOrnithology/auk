#' Reference to eBird data file
#'
#' Create a reference to an eBird Basic Dataset (EBD) file in preparation for
#' filtering using AWK.
#'
#' @param file character; input file. If file is not found as specified, it will
#'   be looked for in the directory specified by the `EBD_PATH` environment
#'   variable.
#' @param file_sampling character; optional input sampling event data (i.e.
#'   checklists) file, required if you intend to zero-fill the data to produce a
#'   presence-absence data set. This file consists of just effort information
#'   for every eBird checklist. Any species not appearing in the EBD for a given
#'   checklist is implicitly considered to have a count of 0. This file should
#'   be downloaded at the same time as the basic dataset to ensure they are in
#'   sync. If file is not found as specified, it will be looked for in the
#'   directory specified by the `EBD_PATH` environment variable.
#' @param sep character; the input field separator, the eBird data are tab
#'   separated so this should generally not be modified. Must only be a single
#'   character and space delimited is not allowed since spaces appear in many of
#'   the fields.
#'
#' @details 
#' eBird data can be downloaded as a tab-separated text file from the 
#' [eBird website](http://ebird.org/ebird/data/download) after submitting a 
#' request for access. As of February 2017, this file is nearly 150 GB making it
#' challenging to work with. If you're only interested in a single species or a
#' small region it is possible to submit a custom download request. This
#' approach is suggested to speed up processing time.
#'
#' There are two potential pathways for preparing eBird data. Users wishing to
#' produce presence only data, should download the 
#' [eBird Basic Dataset](http://ebird.org/ebird/data/download/) and reference 
#' this file when calling `auk_ebd()`. Users wishing to produce zero-filled,
#' presence absence data should additionally download the sampling event data
#' file associated with the basic dataset This file contains only checklist
#' information and can be used to infer absences. The sampling event data file
#' should be provided to `auk_ebd()` via the `file_sampling` argument. For
#' further details consult the vignettes.
#'
#' @return An `auk_ebd` object storing the file reference and the desired
#'   filters once created with other package functions.
#' @export
#' @family objects
#' @examples
#' # get the path to the example data included in the package
#' # in practice, provide path to ebd, e.g. f <- "data/ebd_relFeb-2018.txt
#' f <- system.file("extdata/ebd-sample.txt", package = "auk")
#' auk_ebd(f)
#' # to produce zero-filled data, provide a checklist file
#' f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
#' f_cl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
#' auk_ebd(f_ebd, file_sampling = f_cl)
auk_ebd <- function(file, file_sampling, sep = "\t") {
  # checks
  assertthat::assert_that(
    assertthat::is.string(sep), nchar(sep) == 1, sep != " "
  )
  file <- ebd_file(file)
  # read header rows
  header <- tolower(get_header(file, sep))
  header <- stringr::str_replace_all(header, "[^a-z0-9]+", " ")
  # fix for custom download
  header[header == "state province"] <- "state"
  header[header == "subnational1 code"] <- "state code"
  col_idx <- data.frame(id = NA_character_, 
                        name = header, 
                        index = seq_along(header),
                        stringsAsFactors = FALSE)
  
  # ensure key columns are present
  mandatory <- c("scientific name",
                 "country code", "state code",
                 "latitude", "longitude",
                 "observation date", "time observations started",
                 "protocol type",
                 "duration minutes", "effort distance km",
                 "all species reported",
                 "sampling event identifier", "group identifier")
  col_miss <- mandatory[!(mandatory %in% header)]
  if (length(col_miss) > 0) {
    m <- sprintf("Required columns missing from the EBD file:\n\t%s",
                 paste(col_miss, collapse = "\n\t"))
    stop(m)
  }
  
  # identify columns required for filtering
  filter_cols <- data.frame(
    id = c("species",
           "country", "state", "bcr",
           "lat", "lng", 
           "date", "time", "last_edited",
           "protocol", "project", 
           "duration", "distance", 
           "breeding", "complete"),
    name = c("scientific name",
             "country code", "state code", "bcr code",
             "latitude", "longitude",
             "observation date", "time observations started",
             "last edited date", 
             "protocol type", "project code",
             "duration minutes", "effort distance km",
             "breeding bird atlas code",
             "all species reported"),
    stringsAsFactors = FALSE)
  filter_cols <- filter_cols[filter_cols$name %in% col_idx$name, ]
  col_idx$id[match(filter_cols$name, col_idx$name)] <- filter_cols$id
  
  # process sampling data header
  if (!missing(file_sampling)) {
    file_sampling <- ebd_file(file_sampling)
    # variables not in sampling data
    not_in_sampling <- c("species", "breeding")
    filter_cols_sampling <- filter_cols[!filter_cols$id %in% not_in_sampling, ]
    # read header rows
    header_sampling <- tolower(get_header(file_sampling, sep))
    # ensure key columns are present
    mandatory_sampl <- setdiff(mandatory, "scientific name")
    col_miss <- mandatory_sampl[!(mandatory_sampl %in% header)]
    if (length(col_miss) > 0) {
      m <- sprintf("Required columns missing from the sampling file:\n\t%s",
                   paste(mandatory, collapse = "\n\t"))
      stop(m)
    }
    # identify column locations
    col_idx_sampling <- data.frame(id = NA_character_, 
                                   name = header_sampling, 
                                   index = seq_along(header_sampling),
                                   stringsAsFactors = FALSE)
    col_found <- filter_cols_sampling$name %in% col_idx$name
    filter_cols_sampling <- filter_cols_sampling[col_found, ]
    mtch <- match(filter_cols_sampling$name, col_idx_sampling$name)
    col_idx_sampling$id[mtch] <- filter_cols_sampling$id
  } else {
    file_sampling <- NULL
    col_idx_sampling <- NULL
  }

  # output
  structure(
    list(
      file = file,
      file_sampling = file_sampling,
      output = NULL,
      output_sampling = NULL,
      col_idx = col_idx,
      col_idx_sampling = col_idx_sampling,
      filters = list(
        species = character(),
        country = character(),
        state = character(),
        bcr = integer(),
        bbox = numeric(),
        date = character(),
        time = character(),
        last_edited = character(),
        protocol = character(), 
        project = character(),
        duration = numeric(),
        distance = numeric(),
        breeding = FALSE,
        complete = FALSE
      )
    ),
    class = "auk_ebd"
  )
}

#' @export
print.auk_ebd <- function(x, ...) {
  cat("Input \n")
  cat(paste("  EBD:", x$file, "\n"))
  if (!is.null(x$file_sampling)) {
    cat(paste("  Sampling events:", x$file_sampling, "\n"))
  }
  cat("\n")

  cat("Output \n")
  if (is.null(x$output)) {
    cat("  Filters not executed\n")
  } else {
    cat(paste("  EBD:", x$output, "\n"))
    if (!is.null(x$output_sampling)) {
      cat(paste("  Sampling events:", x$output_sampling, "\n"))
    }
  }
  cat("\n")

  cat("Filters \n")
  # species filter
  cat("  Species: ")
  if (length(x$filters$species) == 0) {
    cat("all")
  } else if (length(x$filters$species) <= 10) {
    cat(paste(x$filters$species, collapse = ", "))
  } else {
    cat(paste0(length(x$filters$species), " species"))
  }
  cat("\n")
  # country filter
  cat("  Countries: ")
  if (length(x$filters$country) == 0) {
    cat("all")
  } else if (length(x$filters$country) <= 10) {
    cat(paste(x$filters$country, collapse = ", "))
  } else {
    cat(paste0(length(x$filters$country), " countries"))
  }
  cat("\n")
  # state filter
  cat("  States: ")
  if (length(x$filters$state) == 0) {
    cat("all")
  } else if (length(x$filters$state) <= 10) {
    cat(paste(x$filters$state, collapse = ", "))
  } else {
    cat(paste0(length(x$filters$state), " states"))
  }
  cat("\n")
  # bcr filter
  cat("  BCRs: ")
  if (length(x$filters$bcr) == 0) {
    cat("all")
  } else if (length(x$filters$bcr) <= 10) {
    cat(paste(x$filters$bcr, collapse = ", "))
  } else {
    cat(paste0(length(x$filters$bcr), " BCRs"))
  }
  cat("\n")
  # bbox filter
  cat("  Bounding box: ")
  e <- round(x$filters$bbox, 1)
  if (length(e) == 0) {
    cat("full extent")
  } else {
    cat(paste0("Lon ", e[1], " - ", e[3], "; "))
    cat(paste0("Lat ", e[2], " - ", e[4]))
  }
  cat("\n")
  # date filter
  cat("  Date: ")
  if (length(x$filters$date) == 0) {
    cat("all")
  } else {
    cat(paste0(x$filters$date[1], " - ", x$filters$date[2]))
  }
  cat("\n")
  # time filter
  cat("  Start time: ")
  if (length(x$filters$time) == 0) {
    cat("all")
  } else {
    cat(paste0(x$filters$time[1], "-", x$filters$time[2]))
  }
  cat("\n")
  # last edited date filter
  cat("  Last edited date: ")
  if (length(x$filters$last_edited) == 0) {
    cat("all")
  } else {
    cat(paste0(x$filters$last_edited[1], " - ", x$filters$last_edited[2]))
  }
  cat("\n")
  # protocol filter
  cat("  Protocol: ")
  if (length(x$filters$protocol) == 0) {
    cat("all")
  } else {
    cat(paste(x$filters$protocol, collapse = ", "))
  }
  cat("\n")
  # project filter
  cat("  Project code: ")
  if (length(x$filters$project) == 0) {
    cat("all")
  } else {
    cat(paste(x$filters$project, collapse = ", "))
  }
  cat("\n")
  # duration filter
  cat("  Duration: ")
  if (length(x$filters$duration) == 0) {
    cat("all")
  } else {
    cat(paste0(x$filters$duration[1], "-", x$filters$duration[2], " minutes"))
  }
  cat("\n")
  # distance filter
  cat("  Distance travelled: ")
  if (length(x$filters$distance) == 0) {
    cat("all")
  } else {
    cat(paste0(x$filters$distance[1], "-", x$filters$distance[2], " km"))
  }
  cat("\n")
  # breeding codes
  cat("  Records with breeding codes only: ")
  if (x$filters$breeding) {
    cat("yes")
  } else {
    cat("no")
  }
  cat("\n")
  # complete checklists only
  cat("  Complete checklists only: ")
  if (x$filters$complete) {
    cat("yes")
  } else {
    cat("no")
  }
  cat("\n")
}
