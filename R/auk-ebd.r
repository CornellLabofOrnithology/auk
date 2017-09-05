#' Reference to eBird data file
#'
#' Create a reference to an eBird Basic Dataset (EBD) file in preparation for
#' filtering using AWK.
#'
#' @param file character; input file.
#' @param file_sampling character; optional input sampling event data file,
#'   required if you intend to zero-fill the data to produce a presence-absence
#'   data set. The sampling file consists of just effort information for every
#'   eBird checklist. Any species not appearing in the EBD for a given checklist
#'   is implicitly considered to have a count of 0. This file should be
#'   downloaded at the same time as the basic dataset to ensure they are in
#'   sync.
#' @param sep character; the input field separator, the eBird data are tab
#'   separated so this should generally not be modified. Must only be a single
#'   character and space delimited is not allowed since spaces appear in many of
#'   the fields.
#'
#' @details eBird data can be downloaded as a tab-separated text file from the
#'   [eBird website](http://ebird.org/ebird/data/download) after submitting a
#'   request for access. As of February 2017, this file is nearly 150 GB making
#'   it challenging to work with. If you're only interested in a single species
#'   or a small region it is possible to submit a custom download request. This
#'   approach is suggested to speed up processing time.
#'
#' @details
#' There are two potential pathways for preparing eBird data. Users wishing to
#' produce presence only data, should download the [eBird Basic Dataset](http://ebird.org/ebird/data/download/)
#' and reference this file when calling `auk_ebd()`. Users wishing to produce
#' zero-filled, presence absence data should additionally download the sampling
#' event data file associated with the basic dataset This file contains only
#' checklist information and can be used to infer absences. The sampling event
#' data file should be provided to `auk_ebd()` via the `file_sampling` argument.
#' For further details consult the vignettes.
#'
#' @return An `auk_ebd` object storing the file reference and the desired
#'   filters once created with other package functions.
#' @export
#' @examples
#' # set up reference to sample file
#' f <- system.file("extdata/ebd-sample.txt", package = "auk")
#' auk_ebd(f)
#' # to produce zero-filled data, provide a sampling event data file
#' f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
#' f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
#' auk_ebd(f_ebd, file_sampling = f_smpl)
auk_ebd <- function(file, file_sampling, sep = "\t") {
  # checks
  assertthat::assert_that(
    file.exists(file),
    assertthat::is.string(sep), nchar(sep) == 1, sep != " "
  )

  # read header rows
  header <- tolower(get_header(file, sep))

  # identify columns required for filtering
  col_idx <- data.frame(
    id = c("species",
           "country", "lat", "lng",
           "date", "time", "last_edited",
           "duration", "complete"),
    name = c("scientific name",
             "country code", "latitude", "longitude",
             "observation date", "time observations started",
             "last edited date",
             "duration minutes", "all species reported"),
    stringsAsFactors = FALSE)
  # all these columns should be in header
  if (!all(col_idx$name %in% header)) {
    stop("Problem parsing header in EBD file.")
  }
  col_idx$index <- match(col_idx$name, header)

  # process sampling data header
  if (!missing(file_sampling)) {
    assertthat::assert_that(
      file.exists(file_sampling)
    )
    file_sampling <- normalizePath(file_sampling)
    # species not in sampling data
    col_idx_sampling <- col_idx[col_idx$id != "species", ]
    # read header rows
    header_sampling <- tolower(get_header(file_sampling, sep))
    # all these columns should be in header
    if (!all(col_idx_sampling$name %in% header_sampling)) {
      stop("Problem parsing header in EBD file.")
    }
    col_idx_sampling$index <- match(col_idx_sampling$name, header_sampling)

  } else {
    file_sampling <- NULL
    col_idx_sampling <- NULL
  }

  # output
  structure(
    list(
      file = normalizePath(file),
      file_sampling = file_sampling,
      output = NULL,
      output_sampling = NULL,
      col_idx = col_idx,
      col_idx_sampling = col_idx_sampling,
      filters = list(
        species = character(),
        country = character(),
        extent = numeric(),
        date = character(),
        time = character(),
        last_edited = character(),
        duration = numeric(),
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
  # extent filter
  cat("  Spatial extent: ")
  e <- x$filters$extent
  if (length(e) == 0) {
    cat("full extent")
  } else {
    cat(paste0("Lat ", round(e[1]), " - ", round(e[3]), "; "))
    cat(paste0("Lon ", round(e[2]), " - ", round(e[4])))
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
  cat("  Time: ")
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
  # duration filter
  cat("  Duration: ")
  if (length(x$filters$duration) == 0) {
    cat("all")
  } else {
    cat(paste0(x$filters$duration[1], "-", x$filters$duration[2], " minutes"))
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
