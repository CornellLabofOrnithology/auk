#' Set a custom path to AWK executable
#' 
#' If AWK has been installed in a non-standard location, the environment 
#' variable `AWK_PATH` must be set to specify the location of the executable. 
#' This function is a helper for editing the .Renviron file to add this path. 
#' **Most users should NOT set `AWK_PATH`, only do so if you have installed AWK 
#' in non-standard location and `auk` cannot find it.**
#'
#' @param path character; path to the AWK executable on your system, e.g. 
#' `"C:/cygwin64/bin/gawk.exe"` or `"/usr/bin/awk"`.
#'
#' @return Opens .Renviron for editing and returns the AWK path invisibly.
#' @export
#' @family paths
#' @examples
#' \dontrun{
#' auk_set_awk_path("/usr/bin/awk")
#' }
auk_set_awk_path <- function(path) {
  assertthat::assert_that(
    assertthat::is.string(path),
    file.exists(path)
  )
  path <- normalizePath(path, mustWork = TRUE)
  # make sure awk executable is there
  awk_test <- tryCatch(
    list(result = system(paste(path, "--version"),
                         intern = TRUE, ignore.stderr = TRUE)),
    error = function(e) list(result = NULL),
    warning = function(e) list(result = NULL)
  )
  if (is.null(awk_test$result) || awk_test$result == "") {
    stop("Specified AWK_PATH doesn't contain a valid AWK executable.")
  }
  # open .Renviron to set path
  edit_r_environ(paste0("AWK_PATH=", path))
  invisible(path)
}