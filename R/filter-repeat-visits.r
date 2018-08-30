#' Filter observations to repeat visits for hierarchical modeling
#' 
#' Hierarchical modeling of abundance and occurrence requires repeat visits to
#' sites to estimate detectability. These visits should be all be within a
#' period of closure, i.e. when the population can be assumed to be closed.
#' eBird data, and many other data sources, do not explicitly follow this
#' protocol; however, subsets of the data can be extracted to produce data
#' suitable for hierarchical modeling. This function extracts a subset of
#' observation data that have a desired number of repeat visits within a period
#' of closure.
#'
#' @param x `data.frame`; observation data, e.g. data from the eBird Basic 
#'   Dataset (EBD) zero-filled with [auk_zerofill()]. This function will also 
#'   work with an `auk_zerofill` object, in which case it will be converted to 
#'   a data frame with [collapse_zerofill()].
#'   **Note that these data must for a single species**. 
#' @param min_obs integer; minimum number of observations required for each
#'   site.
#' @param max_obs integer; maximum number of observations allowed for each site.
#' @param n_days integer; number of days defining the temporal length of
#'   closure. Ignored if `annual_closure = TRUE`.
#' @param annual_closure logical; whether the entire year should be treated as
#'   the period of closure. This can be useful, for example, if data are from
#'   one season (e.g. breeding) across multiple years.
#' @param date_var character; column name of the variable in `x` containing the
#'   date. This column should either be in `Date` format or convertible to
#'   `Date` format with [as.Date()].
#' @param site_vars charcter; names of one of more columns in `x` that define a
#'   site, typically the location and observer IDs.
#'   
#' @details In addition to specifying the minimum and maximum number of
#'   observations per site, users must specify the variables in the dataset that
#'   define a "site". This is typically a combination of IDs defining the
#'   geographic site and the unique observer (repeat visits are meant to be
#'   conducted by the same observer). Finally, the number of days defining the 
#'   period of closure is required. A default value of 14 days is used; however, 
#'   users should choose a suitable period for their species within which the 
#'   population can reasonably be assumed to be closed.
#'
#' @return A `data.frame` filtered to only retain observations from sites with
#'   the allowed number of observations within the period of closure. The
#'   results will be sorted such that sites are together and in chronological
#'   order. The following variables are added to the data frame:
#'   
#'   - `site`: a unique identifier for each "site" corresponding to all the 
#'   variables in `site_vars` and `closure_id` concatenated together with 
#'   underscore separators.
#'   - `closure_id`: a unique ID for each closure period. If
#'   `annual_closure = TRUE`, this will be the year. Otherwise, it will be the 
#'   number of blocks of `n_days` days since the earliest observation. Note that 
#'   in this latter case, there may be gaps in the IDs.
#'   - `n_observations`: number of observations at each site after all 
#'   filtering.
#'   
#' @export
#' @family modeling
#' @examples
#' # read and zero-fill the ebd data
#' f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
#' f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
#' # data must be for a single species
#' ebd_zf <- auk_zerofill(x = f_ebd, sampling_events = f_smpl,
#'                        species = "Collared Kingfisher",
#'                        collapse = TRUE)
#' filter_repeat_visits(ebd_zf, n_days = 30)
filter_repeat_visits <- function(x, min_obs = 2L, max_obs = 10L, 
                                 n_days = 14L, annual_closure = FALSE,
                                 date_var = "observation_date",
                                 site_vars = c("locality_id", "observer_id")) {
  # checks
  if (inherits(x, "auk_zerofill")) {
    x <- collapse_zerofill(x)
  }
  stopifnot(is.data.frame(x))
  stopifnot(is_integer(min_obs), length(min_obs) == 1, isTRUE(min_obs > 0),
            is_integer(max_obs), length(max_obs) == 1, isTRUE(max_obs > 0),
            is_integer(n_days), length(n_days) == 1, isTRUE(n_days > 0)) 
  stopifnot(is.logical(annual_closure), length(annual_closure) == 1)
  stopifnot(is.character(date_var), length(date_var) == 1,
            date_var %in% names(x))
  stopifnot(is.character(site_vars), all(site_vars %in% names(x)))
  # can't have variables overlapping with added variables
  prohibit <- c("site", "closure_id", "n_observations")
  if (any(prohibit %in% names(x))) {
    stop(sprintf("Input data frame cannot have variables named: %s",
                 paste(prohibit, collapse = ", ")))
  }
  
  # date blocks - groups of length n_days
  if (annual_closure) {
    x$closure_id <- format(as.Date(x[[date_var]]), "%Y")
  } else {
    x$closure_id <- as.integer(as.Date(x[[date_var]]))
    x$closure_id <- x$closure_id - min(x$closure_id) + 1
    x$closure_id <- x$closure_id %/% n_days
  }
  
  # group by site_vars and closure_id
  block_vars <- c(site_vars, "closure_id")
  x <- tidyr::unite_(x, "site", block_vars, remove = FALSE)
  
  # get rid of blocks with fewer than min_obs observations
  x_out <- dplyr::group_by(x, .data$site)
  x_out <- dplyr::filter(x_out, dplyr::n() >= min_obs)
  # only keep max_obs observations per block
  x_out <- dplyr::filter(x_out, 
                         sample.int(dplyr::n()) <= min(dplyr::n(), max_obs))
  # add number of obs per site checklist
  x_out <- dplyr::mutate(x_out, n_observations = dplyr::n())
  x_out <- dplyr::ungroup(x_out)
  
  # output
  sort_vars <- rlang::syms(c(site_vars, date_var))
  x_out <- dplyr::arrange(x_out, rlang::UQS(sort_vars))
  dplyr::select(x_out, .data$site, .data$closure_id, .data$n_observations,
                dplyr::everything())
}
