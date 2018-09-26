#' Get the EBD version and associated taxonomy version
#' 
#' Based on the filename of eBird Basic Dataset (EBD) or sampling event data, 
#' determine the version (i.e. release date) of this EBD. Also determine the 
#' corresponding taxonomy version. The eBird taxonomy is updated annually in 
#' August.
#'
#' @param x filename of EBD of sampling event data file, `auk_ebd` object, or
#'   `auk_sampling` object.
#' @param check_exists logical; should the file be checked for existence before 
#'   processing. If `check_exists = TRUE` and the file does not exists, the 
#'   function will raise an error.
#'
#' @return A list with two elements:
#' 
#'   - `ebd_version`: a date object specifying the release date of the EBD.
#'   - `taxonomy_version`: the year of the taxonomy used in this EBD.
#'   
#'  Both elements will be NA if an EBD version cannot be extracted from the 
#'  filename.
#'   
#' @export
#' @family helpers
#' @examples
#' auk_ebd_version("ebd_relAug-2018.txt", check_exists = FALSE)
auk_ebd_version <- function(x, check_exists = TRUE) {
  UseMethod("auk_ebd_version")
}

#' @export
auk_ebd_version.character <- function(x, check_exists = TRUE) {
  if (check_exists) {
    x <- ebd_file(x)
  }
  x <- basename(x)
  
  # get date from filename
  regex <- paste0("((", paste(month.abb, collapse = ")|("), "))-[0-9]{4}")
  ebd_date <- stringr::str_extract(x, regex)
  if (is.na(ebd_date)) {
    return(list(ebd_version = NA, taxonomy_version = NA))
  }
  ebd_date <- stringr::str_split(ebd_date, "-", n = 2)[[1]]
  mth <- match(ebd_date[1], month.abb)
  yr <- as.integer(ebd_date[2])
  ebd_date <- paste(yr, mth, "1", sep = "-")
  ebd_date <- as.Date(ebd_date, format = "%Y-%m-%d")
  if (is.na(ebd_date) || !inherits(ebd_date, "Date")) {
    return(list(ebd_version = NA, taxonomy_version = NA))
  }
  
  # determine taxonomy version
  if (mth < 8) {
    tax <- yr - 1
  } else {
    tax <- yr
  }
  return(list(ebd_version = ebd_date, taxonomy_version = tax))
}

#' @export
auk_ebd_version.auk_ebd <- function(x, check_exists = TRUE) {
  auk_ebd_version.character(x$file, check_exists = check_exists)
}

#' @export
auk_ebd_version.auk_sampling <- function(x, check_exists = TRUE) {
  auk_ebd_version.character(x$file, check_exists = check_exists)
}
