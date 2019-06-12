#' Set a custom path to AWK executable
#' 
#' If AWK has been installed in a non-standard location, the environment
#' variable `AWK_PATH` must be set to specify the location of the executable.
#' Use this function to set `AWK_PATH` in your .Renviron file. **Most users
#' should NOT set `AWK_PATH`, only do so if you have installed AWK in
#' non-standard location and `auk` cannot find it.**
#'
#' @param path character; path to the AWK executable on your system, e.g. 
#'   `"C:/cygwin64/bin/gawk.exe"` or `"/usr/bin/awk"`.
#' @param overwrite logical; should the existing `AWK_PATH` be overwritten if it
#'   has already been set in .Renviron.
#'
#' @return Edits .Renviron, then returns the AWK path invisibly.
#' @export
#' @family paths
#' @examples
#' \dontrun{
#' auk_set_awk_path("/usr/bin/awk")
#' }
auk_set_awk_path <- function(path, overwrite = FALSE) {
  assertthat::assert_that(
    assertthat::is.string(path),
    file.exists(path)
  )
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
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
  
  # find .Renviron
  renv_path <- path.expand(file.path("~", ".Renviron"))
  if (!file.exists(renv_path)) {
    file.create(renv_path)
  }
  renv_lines <- readLines(renv_path)
  
  # look for existing entry, remove if overwrite = TRUE
  renv_exists <- grepl("^AWK_PATH[[:space:]]*=.*", renv_lines)
  if (any(renv_exists)) {
    if (overwrite) {
      # drop existing
      writeLines(renv_lines[!renv_exists], renv_path)
    } else {
      stop(
        "AWK_PATH already set, use overwrite = TRUE to overwite existing path."
      )
    }
  }
  # set path in .Renviron
  write(paste0("AWK_PATH='", path, "'\n"), renv_path, append = TRUE)
  message(paste("AWK_PATH set to", path))
  invisible(path)
}