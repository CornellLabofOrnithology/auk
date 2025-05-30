#' Reference to eBird sampling event file
#'
#' Create a reference to an eBird sampling event file in preparation for
#' filtering using AWK. For working with the sightings data use `auk_ebd()`,
#' only use `auk_sampling()` if you intend to only work with checklist-level
#' data.
#'
#' @param file character; input sampling event data file, which contains 
#'   checklist data from eBird.
#' @param sep character; the input field separator, the eBird data are tab
#'   separated so this should generally not be modified. Must only be a single
#'   character and space delimited is not allowed since spaces appear in many of
#'   the fields.
#'
#' @details eBird data can be downloaded as a tab-separated text file from the
#'   [eBird website](http://ebird.org/ebird/data/download) after submitting a
#'   request for access. In the eBird Basic Dataset (EBD) each row corresponds 
#'   to a observation of a single bird species on a single checklist, while the 
#'   sampling event data file contains a single row for every checklist. This 
#'   function creates an R object to reference only the sampling data.
#'
#' @return An `auk_sampling` object storing the file reference and the desired
#'   filters once created with other package functions.
#' @export
#' @family objects
#' @examples
#' # get the path to the example data included in the package
#' # in practice, provide path to the sampling event data
#' # e.g. f <- "data/ebd_sampling_relFeb-2018.txt"
#' f <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
#' auk_sampling(f)
auk_sampling <- function(file, sep = "\t") {
  # checks
  assertthat::assert_that(
    assertthat::is.string(sep), nchar(sep) == 1, sep != " "
  )
  file <- ebd_file(file)
  # read header rows
  header <- tolower(get_header(file, sep))
  header <- stringr::str_replace_all(header, "_", " ")
  col_idx <- data.frame(id = NA_character_, 
                        name = header, 
                        index = seq_along(header),
                        stringsAsFactors = FALSE)
  
  # check column name for protocol column
  protocol_col_name <- "protocol name"
  if (!protocol_col_name %in% header) {
    protocol_col_name <- "protocol type"
  }
  # check column name for project column
  project_col_name <- "project names"
  if (!project_col_name %in% header) {
    project_col_name <- "project code"
  }
  
  # ensure key columns are present
  mandatory <- c("country code", "state code",
                 "latitude", "longitude",
                 "observation date", "time observations started",
                 protocol_col_name,
                 "duration minutes", "effort distance km",
                 "all species reported",
                 "sampling event identifier", "group identifier")
  col_miss <- mandatory[!(mandatory %in% header)]
  if (length(col_miss) > 0) {
    m <- sprintf("Required columns missing from the sampling file:\n\t%s",
                 paste(col_miss, collapse = "\n\t"))
    stop(m)
  }
  
  # identify columns required for filtering
  filter_cols <- data.frame(
    id = c("country", "state", "county", "bcr", 
           "lat", "lng",
           "date", "time", "last_edited",
           "protocol", "project", 
           "duration", "distance", 
           "complete",
           "observer"),
    name = c("country code", "state code", "county code", "bcr code",
             "latitude", "longitude",
             "observation date", "time observations started",
             "last edited date", 
             protocol_col_name, project_col_name,
             "duration minutes", "effort distance km",
             "all species reported",
             "observer id"),
    stringsAsFactors = FALSE)
  filter_cols <- filter_cols[filter_cols$name %in% col_idx$name, ]
  col_idx$id[match(filter_cols$name, col_idx$name)] <- filter_cols$id
  
  # output
  structure(
    list(
      file = normalizePath(file),
      output = NULL,
      col_idx = col_idx,
      filters = list(
        country = character(),
        state = character(),
        county = character(),
        bbox = numeric(),
        year = integer(),
        date = character(),
        time = character(),
        last_edited = character(),
        protocol = character(), 
        project = character(),
        duration = numeric(),
        distance = numeric(),
        complete = FALSE,
        observer = character()
      )
    ),
    class = "auk_sampling"
  )
}

#' @export
print.auk_sampling <- function(x, ...) {
  cat("Input \n")
  cat(paste("  Sampling events:", x$file, "\n"))
  cat("\n")
  
  cat("Output \n")
  if (is.null(x$output)) {
    cat("  Filters not executed\n")
  } else {
    cat(paste("  Sampling events:", x$output, "\n"))
  }
  cat("\n")
  
  cat("Filters \n")
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
  # state filter
  cat("  Counties: ")
  if (length(x$filters$county) == 0) {
    cat("all")
  } else if (length(x$filters$county) <= 10) {
    cat(paste(x$filters$county, collapse = ", "))
  } else {
    cat(paste0(length(x$filters$county), " counties"))
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
  # year filter
  cat("  Years: ")
  if (length(x$filters$year) == 0) {
    cat("all")
  } else if (length(x$filters$year) <= 10) {
    cat(paste(x$filters$year, collapse = ", "))
  } else {
    cat(paste0(length(x$filters$year), " years"))
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
  # complete checklists only
  cat("  Complete checklists only: ")
  if (x$filters$complete) {
    cat("yes")
  } else {
    cat("no")
  }
  cat("\n")
}
