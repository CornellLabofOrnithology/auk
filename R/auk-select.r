#' Select a subset of columns
#' 
#' Select a subset of columns from the eBird Basic Dataset (EBD) or the sampling 
#' events file. Subsetting the columns can significantly decrease file size.
#'
#' @param x `auk_ebd` or `auk_sampling` object; reference to file created by 
#'   [auk_ebd()] or [auk_sampling()].
#' @param select character; a character vector specifying the names of the
#'   columns to select. Columns should be as they appear in the header of the
#'   EBD; however, names are not case sensitive and spaces may be replaced by
#'   underscores, e.g. `"COMMON NAME"`, `"common name"`, and `"common_NAME"` are
#'   all valid.
#' @param file character; output file.
#' @param sep character; the input field separator, the eBird file is tab
#'   separated by default. Must only be a single character and space delimited
#'   is not allowed since spaces appear in many of the fields.
#' @param overwrite logical; overwrite output file if it already exists
#'
#' @return Invisibly returns the filename of the output file.
#' @export
#' @family text
#' @examples
#' \dontrun{
#' # select a minimal set of columns
#' out_file <- tempfile()
#' ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
#' cols <- c("latitude", "longitude",
#'           "group identifier", "sampling event identifier", 
#'           "scientific name", "observation count",
#'           "observer_id")
#' selected <- auk_select(ebd, select = cols, file = out_file)
#' str(read_ebd(selected))
#' }
auk_select <- function(x, select, file, sep = "\t", overwrite = FALSE) {
  UseMethod("auk_select")
}

#' @export
auk_select.auk_ebd <- function(x, select, file, sep = "\t", overwrite = FALSE) {
  # checks
  awk_path <- auk_get_awk_path()
  assertthat::assert_that(
    is.character(select),
    assertthat::is.string(file)
  )
  if (!dir.exists(dirname(file))) {
    stop("Output directory doesn't exist.")
  }
  if (!overwrite && file.exists(file)) {
    stop("Output file already exists, use overwrite = TRUE.")
  }
  file <- normalizePath(file, winslash = "/", mustWork = FALSE)
  # selected columns
  select <- tolower(select)
  select <- stringr::str_replace_all(select, "_", " ")
  found <- select %in% x$col_idx$name
  if (!all(found)) {
    col_miss <- paste(select[!found], collapse = ", ")
    stop(paste("Selected variable not found in header: \n\t", col_miss))
  }
  # certain columns must be kept
  must_keep <- c("group identifier", "sampling event identifier",
                 "scientific name", "observation count")
  must_keep <- intersect(must_keep, x$col_idx$name)
  if (!all(must_keep %in% select)) {
    m <- paste("The following columns must be retained:",
               paste(setdiff(must_keep, select), collapse = ", "))
    stop(m)
  }
  # find column numbers
  idx <- x$col_idx$index[x$col_idx$name %in% select]
  select_cols <- paste0("$", idx, collapse = ", ")
  # generate awk script
  awk_script <- stringr::str_interp(awk_select, 
                                    list(sep = sep, select = select_cols))
  # run
  exit_code <- system2(awk_path,
                       args = paste0("'", awk_script, "' '", x$file, "'"),
                       stdout = file, stderr = FALSE)
  if (exit_code != 0) {
    stop("Error running AWK command.")
  }
  invisible(file)
}

#' @export
auk_select.auk_sampling <- function(x, select, file, sep = "\t", 
                                    overwrite = FALSE) {
  auk_select.auk_ebd(x, select, file, sep, overwrite)
}

# awk script template
awk_select <- "
BEGIN {
FS = \"${sep}\"
OFS = \"${sep}\"
}
{
  print ${select}
}
"
