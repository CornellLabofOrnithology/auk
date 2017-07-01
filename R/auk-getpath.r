#' OS specific path to AWK
#'
#' Return the OS specific path to AWK, or highlights if it's not installed.
#'
#' @return Path to AWK or `NA` if AWK wasn't found.
#' @export
#' @examples
#' auk_getpath()
auk_getpath <- function() {
  sysname <- tolower(Sys.info()[["sysname"]])

  # mac or linux
  if (sysname %in% c("darwin", "linux")) {
    # test
    awk_test <- tryCatch(
      list(result = system("which awk", intern = TRUE, ignore.stderr = TRUE)),
      error = function(e) list(result = NULL),
      warning = function(e) list(result = NULL)
    )
    # set path
    awk <- awk_test$result
  } else if (sysname == "windows") {
    # cygwin or cygwin64?
    if (file.exists("C:/cygwin64/bin/gawk.exe")) {
      awk <- "C:/cygwin64/bin/gawk.exe"
    } else if (file.exists("C:/cygwin/bin/gawk.exe")) {
      awk <- "C:/cygwin/bin/gawk.exe"
    } else {
      return(NA_character_)
    }
    # test
    awk_test <- tryCatch(
      list(result = system(paste(awk, "--version"),
                           intern = TRUE, ignore.stderr = TRUE)),
      error = function(e) list(result = NULL),
      warning = function(e) list(result = NULL)
    )
  } else {
    return(NA_character_)
  }

  if (!is.null(awk_test$result)) {
    return(awk)
  } else {
    return(NA_character_)
  }
}
