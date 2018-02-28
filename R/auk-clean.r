#' Clean an eBird data file
#'
#' Some rows in the eBird Basic Dataset (EBD) may have an incorrect number of
#' columns, often resulting from tabs embedded in the comments field. This
#' function drops these problematic records. **Note that this function typically
#' takes at least 3 hours to run on the full dataset**
#'
#' @param f_in character; input file.
#' @param f_out character; output file.
#' @param sep character; the input field separator, the basic dataset is tab
#'   separated by default. Must only be a single character and space delimited
#'   is not allowed since spaces appear in many of the fields.
#' @param remove_text logical; whether all free text entry columns should be 
#'   removed. These columns include comments, location names, and observer 
#'   names. These columns cause import errors due to special characters and 
#'   increase the file size, yet are rarely valuable for analytical 
#'   applications, so may be removed. Setting this argument to `TRUE` can lead 
#'   to a significant reduction in file size.
#' @param overwrite logical; overwrite output file if it already exists
#'
#' @details
#'
#' This function can clean a basic dataset file or a sampling file.
#'
#' Calling this function requires that the command line utility AWK is
#' installed. Linux and Mac machines should have AWK by default, Windows users
#' will likely need to install [Cygwin](https://www.cygwin.com).
#'
#' @return If AWK ran without errors, the output filename is returned,
#'   however, if an error was encountered the exit code is returned.
#' @export
#' @examples
#' \dontrun{
#' # example data with errors
#' f <- system.file("extdata/ebd-sample_messy.txt", package = "auk")
#' tmp <- tempfile()
#'
#' # clean file to remove problem rows
#' auk_clean(f, tmp)
#' # number of lines in input
#' length(readLines(f))
#' # number of lines in output
#' length(readLines(tmp))
#'
#' # note that the extra blank column has also been removed
#' ncol(read.delim(f, nrows = 5, quote = ""))
#' ncol(read.delim(tmp, nrows = 5, quote = ""))
#' }
auk_clean <- function(f_in, f_out, sep = "\t", remove_text = FALSE, 
                      overwrite = FALSE) {
  # checks
  awk_path <- auk_getpath()
  if (is.na(awk_path)) {
    stop("auk_clean() requires a valid AWK install.")
  }
  assertthat::assert_that(
    file.exists(f_in),
    assertthat::is.string(sep), nchar(sep) == 1, sep != " ",
    assertthat::is.flag(remove_text),
    assertthat::is.flag(overwrite)
  )
  # check output file
  if (!dir.exists(dirname(f_out))) {
    stop("Output directory doesn't exist.")
  }
  if (!overwrite && file.exists(f_out)) {
    stop("Output file already exists, use overwrite = TRUE.")
  }
  f_out <- path.expand(f_out)

  # determine number of columns
  # read header row
  header <- get_header(f_in, sep)
  if (header[length(header)] == "") {
    header <- header[-length(header)]
  }
  ncols <- length(header)
  if (ncols < 30) {
    stop(
      sprintf("There is an error in your EBD file, only %i columns detected.",
            ncols)
      )
  }
  
  # columns to drop
  if (remove_text) {
    text_cols <- c("locality", 
                   "first name", "last name", 
                   "trip comments", 
                   "species comments")
    keep_cols <- which(!tolower(header) %in% text_cols)
    print_cols <- paste0("$", keep_cols, collapse = ",")
  } else {
    print_cols <- "$0"
  }
  

  # construct awk command
  awk <- str_interp(awk_clean, 
                    list(sep = sep, ncols = ncols, print_cols = print_cols))

  # run command
  exit_code <- system2(awk_path,
                       args = paste0("'", awk, "' ", f_in),
                       stdout = f_out)
  if (exit_code == 0) {
    f_out
  } else {
    exit_code
  }
}

# awk script template
awk_clean <- "
BEGIN {
  FS = \"${sep}\"
  OFS = \"${sep}\"
}
{
  # remove end of line tab
  sub(/\t$/, \"\", $0)
  # only keep rows with correct number of records
  if (NF == ${ncols} || NR == 1) {
    print ${print_cols}
  }
}
"
