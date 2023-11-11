is_integer <- function(x) {
  is.integer(x) || (is.numeric(x) && all(x == as.integer(x)))
}

get_header <- function(x, sep = "\t") {
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

get_col_types <- function(header) {
  # column types based on feb 2017 ebd
  col_types <- c(
    "GLOBAL UNIQUE IDENTIFIER" = "character",
    "LAST EDITED DATE" = "character",
    "TAXONOMIC ORDER" = "numeric",
    "CATEGORY" = "character",
    "COMMON NAME" = "character",
    "SCIENTIFIC NAME" = "character",
    "SUBSPECIES COMMON NAME" = "character",
    "SUBSPECIES SCIENTIFIC NAME" = "character",
    "EXOTIC CODE" = "character",
    "OBSERVATION COUNT" = "character",
    "BREEDING BIRD ATLAS CODE" = "character",
    "BREEDING BIRD ATLAS CATEGORY" = "character",
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
    "PROTOCOL CODE" = "character",
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
  col_types <- substr(col_types, 1, 1)
  # add in guesses
  col_types <- col_types[header]
  col_types[is.na(col_types)] <- "?"
  col_types <- paste(col_types, collapse = "")
  col_types
}

ebd_file <- function(x, exists = TRUE) {
  p <- auk_get_ebd_path()
  if (file.exists(x)) {
    return(normalizePath(x, winslash = "/"))
  } else if (!is.na(p) && file.exists(file.path(p, x))) {
    return(normalizePath(file.path(p, x), winslash = "/"))
  } else {
    stop(paste("File not found:\n", x))
  }
}