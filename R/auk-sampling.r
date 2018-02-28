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
#' @examples
#' # set up reference to example file
#' f <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
#' auk_sampling(f)
auk_sampling <- function(file, sep = "\t") {
  # checks
  assertthat::assert_that(
    file.exists(file),
    assertthat::is.string(sep), nchar(sep) == 1, sep != " "
  )
  
  # read header rows
  header <- tolower(get_header(file, sep))
  header <- stringr::str_replace_all(header, "_", " ")
  col_idx <- data.frame(id = NA_character_, 
                        name = header, 
                        index = seq_along(header),
                        stringsAsFactors = FALSE)
  
  # identify columns required for filtering
  filter_cols <- data.frame(
    id = c("country", "lat", "lng",
           "date", "time", "last_edited",
           "protocol", "project", 
           "duration", "distance", 
           "complete"),
    name = c("country code", "latitude", "longitude",
             "observation date", "time observations started",
             "last edited date", 
             "protocol type", "project code",
             "duration minutes", "effort distance km",
             "all species reported"),
    stringsAsFactors = FALSE)
  # all these columns should be in header
  if (!all(filter_cols$name %in% col_idx$name)) {
    stop("Problem parsing header in sampling event file.")
  }
  col_idx$id[match(filter_cols$name, col_idx$name)] <- filter_cols$id
  
  # output
  structure(
    list(
      file = normalizePath(file),
      output = NULL,
      col_idx = col_idx,
      filters = list(
        country = character(),
        extent = numeric(),
        date = character(),
        time = character(),
        last_edited = character(),
        protocol = character(), 
        project = character(),
        duration = numeric(),
        distance = numeric(),
        complete = FALSE
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
  # extent filter
  cat("  Spatial extent: ")
  e <- round(x$filters$extent, 1)
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
  # complete checklists only
  cat("  Complete checklists only: ")
  if (x$filters$complete) {
    cat("yes")
  } else {
    cat("no")
  }
  cat("\n")
}
