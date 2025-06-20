#' Set the path to EBD text files
#' 
#' Users of `auk` are encouraged to set the path to the directory containing the
#' eBird Basic Dataset (EBD) text files in the `EBD_PATH` environment variable.
#' All functions referencing the EBD or sampling event data files will check in
#' this directory to find the files, thus avoiding the need to specify the full
#' path every time. This will increase the portability of your code. Use this
#' function to set `EBD_PATH` in your .Renviron file; it is also possible to
#' manually edit the file. This function first looks for for an .Renviron
#' location defined by `R_ENVIRON_USER`, then defaults to ~/.Renviron.
#'
#' @param path character; directory where the EBD text files are stored, e.g. 
#'   `"/home/matt/ebd"`.
#' @param overwrite logical; should the existing `EBD_PATH` be overwritten if it
#'   has already been set in .Renviron.
#'
#' @return Edits .Renviron, sets `EBD_PATH` for the current session, then
#'   returns the EBD path invisibly.
#' @export
#' @family paths
#' @examples
#' \dontrun{
#' auk_set_ebd_path("/home/matt/ebd")
#' }
auk_set_ebd_path <- function(path, overwrite = FALSE) {
  assertthat::assert_that(
    assertthat::is.string(path),
    dir.exists(path)
  )
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  
  # find .Renviron
  renv_path <- renv_file_path()
  renv_lines <- readLines(renv_path)
  
  # look for existing entry, remove if overwrite = TRUE
  renv_exists <- grepl("^EBD_PATH[[:space:]]*=.*", renv_lines)
  if (any(renv_exists)) {
    if (overwrite) {
      # drop existing
      writeLines(renv_lines[!renv_exists], renv_path)
    } else {
      stop(
        "EBD_PATH already set, use overwrite = TRUE to overwite existing path."
      )
    }
  }
  # set path in .Renviron
  write(paste0("EBD_PATH='", path, "'\n"), renv_path, append = TRUE)
  message(paste("EBD_PATH set to", path))
  # set EBD_PATH for this session, so user doesn't have to reload
  Sys.setenv(EBD_PATH = path)
  invisible(path)
}

renv_file_path <- function() {
  stored_path <- Sys.getenv("R_ENVIRON_USER")
  if (stored_path != "") {
    renv <- stored_path
  } else {
    renv <- path.expand(file.path("~", ".Renviron"))
  }
  
  if (!file.exists(renv)) {
    file.create(renv)
  }
  return(renv)
}