#' Process eBird bar chart data
#' 
#' eBird bar charts show the frequency of detection for each week for all
#' species within a region. These can be accessed by visiting any region or
#' hotspot page and clicking the "Bar Charts" link in the left column. As an
#' example, these [bar charts for
#' Guatemala](https://ebird.org/barchart?r=GT&yr=all&m=) list all the species
#' (as well as non-species taxa) that have been observed in eBird in Guatemala
#' and, for each species, the width of the green bar reflects the frequency of
#' detections on eBird checklists within the region (referred to as detection
#' frequency). Detection frequency is provide for each of 4 "weeks" of each
#' month (although these are not technically 7 day weeks since months have more
#' than 28 days). The data underlying the bar charts can be downloaded via a
#' link at the bottom right of the page; however, the text file that's
#' downloaded is in a challenging format to work with. This function is designed
#' to read these text files and return a nicely formatted data frame for use in
#' R.
#'
#' @param filename character; path to the bar chart data text file downloaded
#'   from the eBird website.
#'
#' @return This functions returns a data frame in long format where each row
#'   provides data for one species in one week. `detection_frequency` gives the
#'   proportion of checklists in the region that reported the species in the
#'   given week and `n_detections` gives the number of detections. The total
#'   number of checklists in each week used to estimate detection frequency is
#'   provided as a data frame stored in the `sample_sizes` attribute. Note that
#'   since most months have more than 28 days, the first three weeks have 7
#'   days, but the final week has between 7-10 days.
#'   
#' @export
#' @family helpers
#' @examples
#' # example bar chart data for svalbard
#' f <- system.file("extdata/barchart-sample.txt", package = "auk")
#' # import and process barchart data
#' barcharts <- process_barcharts(f)
#' head(barcharts)
#' 
#' # the sample sizes for each week can be access with
#' attr(barcharts, "sample_sizes")
#' 
#' # bar charts include data for non-species taxa
#' # use category to filter to only species
#' barcharts[barcharts$category == "species", ]
process_barcharts <- function(filename) {
  stopifnot(is.character(filename), file.exists(filename))
  
  l <- readLines(filename)
  l <- l[l != ""]
  
  # column headers
  month_week <- tidyr::expand_grid(month = tolower(month.abb), week = seq_len(4))
  week_vars <- paste(month_week$month, month_week$week, sep = "_")
  
  # number of checklists per week
  ss_row <- which(stringr::str_detect(l, "Sample Size:\t"))
  if (length(ss_row) != 1) {
    stop("The barchart data is in an unexpected format and cannot be read. ",
         "This function can only process unmodified data downloaded directly ",
         "from the eBird website.")
  }
  ss <- stringr::str_remove(l[ss_row], "Sample Size:\t")
  ss <- as.integer(stringr::str_split_1(ss, "\t")[seq_len(48)])
  ss <- dplyr::bind_cols(month_week, n_checklists = ss)
  
  # detection frequency
  detfrq <- l[seq(ss_row + 1, length(l))]
  cn <- c("species_name", week_vars, "blank")
  ct <- c("c", rep("d", times = length(cn) - 2), "c")
  ct <- paste(ct, collapse = "")
  detfrq <- readr::read_tsv(I(detfrq), col_names = cn, col_types = ct)
  detfrq$blank <- NULL
  
  # does this file have common names, scientific names, or both?
  has_sci <- stringr::str_detect(detfrq$species_name[1], '<em class=\"sci\">')
  if (has_sci) {
    detfrq$scientific_name <- stringr::str_extract(
      detfrq$species_name,
      '(?<=<em class="sci">)(.*?)(?=</em>)'
    )
  } else {
    ascii <- stringi::stri_trans_general(detfrq$species_name, "latin-ascii")
    idx <- match(ascii, auk::ebird_taxonomy$common_name)
    if (any(is.na(idx))) {
      stop("Species names could not be matched to the eBird taxonomy. ",
           "This function only works on English common names or ",
           "scientific names. Try modifying your 'Species name display' ",
           "preferences on the eBird website to show either scientific names ",
           "or both common and scientific names.")
    }
    detfrq$scientific_name <- auk::ebird_taxonomy$scientific_name[idx]
  }
  detfrq$species_name <- NULL
  
  # transform to long
  detfrq <- tidyr::pivot_longer(detfrq, cols = -"scientific_name", 
                                values_to = "detection_frequency")
  detfrq <- tidyr::separate(detfrq, col = "name", into = c("month", "week"))
  detfrq$week <- as.integer(detfrq$week)
  detfrq$name <- NULL
  
  # add in species codes
  tax <- auk::ebird_taxonomy
  tax <- tax[, c("species_code", "common_name", "scientific_name", "category")]
  detfrq <- dplyr::inner_join(tax, detfrq, by = "scientific_name")
  
  # add in num detections
  detfrq <- dplyr::inner_join(detfrq, ss, by = c("month", "week"))
  detfrq$n_detections <- round(detfrq$n_checklists * detfrq$detection_frequency)
  detfrq$n_checklists <- NULL
  detfrq <- dplyr::as_tibble(detfrq)
  
  attr(detfrq, "sample_sizes") <- ss
  return(detfrq)
}
