#' Return EBD data path
#' 
#' Returns the environment variable `EBD_PATH`, which users are encouraged to 
#' set to the directory that stores the eBird Basic Dataset (EBD) text files.
#'
#' @return The path stored in the `EBD_PATH` environment variable.
#' @export
#' @family paths
#' @examples
#' auk_get_ebd_path()
auk_get_ebd_path <- function() {
  p <- Sys.getenv("EBD_PATH")
  if (p == "") {
    return(NA_character_)
  } else if (!dir.exists(p)) {
    stop("Directory specified by EBD_PATH does not exist.")
  }
  return(p)
}