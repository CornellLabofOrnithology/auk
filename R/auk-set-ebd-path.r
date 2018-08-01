#' Set the path to EBD text files
#' 
#' Users of `auk` are encouraged to set the path to the directory containing the
#' eBird Basic Dataset (EBD) text files in the `EBD_PATH` environment variable.
#' All functions referencing the EBD or sampling event data files will check in
#' this directory to find the files, thus avoiding the need to specify the full
#' path every time. This will increase the portability of your code. This
#' function is a helper for editing the .Renviron file to add this path, it is
#' also possible to manually edit the file.
#'
#' @param path character; directory where the EBD text files are stored, e.g. 
#' `"/home/matt/ebd"`.
#'
#' @return Opens .Renviron for editing and returns the AWK path invisibly.
#' @export
#' @family paths
#' @examples
#' \dontrun{
#' auk_set_ebd_path("/home/matt/ebd")
#' }
auk_set_ebd_path <- function(path) {
  assertthat::assert_that(
    assertthat::is.string(path),
    dir.exists(path)
  )
  path <- normalizePath(path, mustWork = TRUE)
  # open .Renviron to set path
  edit_r_environ(paste0("EBD_PATH=", path))
  invisible(path)
}