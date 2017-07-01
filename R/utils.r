get_header <- function(x, sep) {
  readLines(x, n = 1) %>%
    stringr::str_split(sep) %>%
    `[[`(1) %>%
    trimws()
}

clean_names <- function(x) {
  x_clean <- tolower(x) %>%
    trimws() %>%
    stringr::str_replace_all("[./ ]", "_")
  x_clean
}

get_col_types <- function(header,
                          reader = c("fread", "readr", "base")) {
  reader <- match.arg(reader)

  # column types based on feb 2017 ebd
  col_types = c(
    "GLOBAL UNIQUE IDENTIFIER" = "character",
    "LAST EDITED DATE" = "character",
    "TAXONOMIC ORDER" = "integer",
    "CATEGORY" = "character",
    "COMMON NAME" = "character",
    "SCIENTIFIC NAME" = "character",
    "SUBSPECIES COMMON NAME" = "character",
    "SUBSPECIES SCIENTIFIC NAME" = "character",
    "OBSERVATION COUNT" = "character",
    "BREEDING BIRD ATLAS CODE" = "character",
    "AGE/SEX" = "character",
    "COUNTRY" = "character",
    "COUNTRY CODE" = "character",
    "STATE" = "character",
    "STATE CODE" = "character",
    "COUNTY" = "character",
    "COUNTY CODE" = "character",
    "IBA CODE" = "character",
    "BCR CODE" = "integer",
    "USFWS CODE" = "character",
    "ATLAS BLOCK" = "character",
    "LOCALITY" = "character",
    "LOCALITY ID" = "character",
    "LOCALITY TYPE" = "character",
    "LATITUDE" = "numeric",
    "LONGITUDE" = "numeric",
    "OBSERVATION DATE" = "Date",
    "TIME OBSERVATIONS STARTED" = "character",
    "OBSERVER ID" = "character",
    "FIRST NAME" = "character",
    "LAST NAME" = "character",
    "SAMPLING EVENT IDENTIFIER" = "character",
    "PROTOCOL TYPE" = "character",
    "PROJECT CODE" = "character",
    "DURATION MINUTES" = "integer",
    "EFFORT DISTANCE KM" = "numeric",
    "EFFORT AREA HA" = "numeric",
    "NUMBER OBSERVERS" = "integer",
    "ALL SPECIES REPORTED" = "logical",
    "GROUP IDENTIFIER" = "character",
    "HAS MEDIA" = "logical",
    "APPROVED" = "logical",
    "REVIEWED" = "logical",
    "REASON" = "character",
    "TRIP COMMENTS" = "character",
    "SPECIES COMMENTS" = "character")

  # remove any columns not in header
  col_types <- col_types[names(col_types) %in% header]

  # make reader specific changes
  if (reader == "fread") {
    col_types[col_types == "logical"] = "integer"
    col_types[col_types == "Date"] = "character"
  } else if (reader == "readr") {
    col_types = substr(col_types, 1, 1)
    # add in guesses
    col_types <- col_types[header]
    col_types[is.na(col_types)] <- "?"
    col_types <- paste(col_types, collapse = "")
  } else {
    col_types[col_types == "logical"] = "integer"
    names(col_types) <- stringr::str_replace_all(names(col_types), "[ /]", ".")
  }
  col_types
}

# set output format
set_class <- function(x, setclass = c("tbl", "data.frame", "data.table")) {
  setclass = match.arg(setclass)
  if (setclass == "data.table" &&
      !requireNamespace("data.table", quietly = TRUE)) {
    stop("data.table package must be installed to return a data.table.")
  }

  if (setclass == "tbl") {
    if (inherits(x, "tbl")) {
      return(x)
    }
    return(structure(x, class = c("tbl_df", "tbl", "data.frame")))
  } else if (setclass == "data.table") {
    if (inherits(x, "data.table")) {
      return(x)
    }
    return(data.table::as.data.table(x))
  } else {
    return(structure(x, class = "data.frame"))
  }
}

choose_reader <- function(x) {
  assertthat::assert_that(is.null(x) || x %in% c("fread", "readr", "base"))

  if (is.null(x)) {
    if (requireNamespace("data.table", quietly = TRUE)) {
      reader <- "fread"
    } else if (requireNamespace("data.table", quietly = TRUE)) {
      reader <- "readr"
    } else {
      reader <- "base"
    }
  } else {
    reader <- x
  }

  if (reader == "fread") {
    if (!requireNamespace("data.table", quietly = TRUE)) {
      stop("Install the data.table package to use reader = fread.")
    }
  } else if (reader == "readr") {
    if (!requireNamespace("readr", quietly = TRUE)) {
      stop("Install the readr package to use reader = readr.")
    }
  } else {
    m <- paste("read.delim is slow for large EBD files, for better performance",
               "insall the readr or data.table packages.")
    warning(m)
  }
  return(reader)
}
