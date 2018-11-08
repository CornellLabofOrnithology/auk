#' Format EBD data for occupancy modeling with `unmarked`
#' 
#' Prepare a data frame of species observations for ingestion into the package
#' `unmarked` for hierarchical modeling of abundance and occurrence. The
#' function [unmarked::formatWide()] takes a data frame and converts it to one
#' of several `unmarked` objects, which can then be used for modeling. This
#' function converts data from a format in which each row is an observation
#' (e.g. as in the eBird Basic Dataset) to the esoteric format required by
#' [unmarked::formatWide()] in which each row is a site.
#'
#' @param x `data.frame`; observation data, e.g. from the eBird Basic Dataset
#'   (EBD), for **a single species**, that has been filtered to those with 
#'   repeat visits by [filter_repeat_visits()].
#' @param site_id character; a unique idenitifer for each "site", typically 
#'   identifying observations from a unique location by the same observer 
#'   within a period of temporal closure. Data output from 
#'   [filter_repeat_visits()] will have a `.site_id` variable that meets these 
#'   requirements.
#' @param response character; the variable that will act as the response in 
#'   modeling efforts, typically a binary variable indicating presence or 
#'   absence or a count of individuals seen.
#' @param site_covs character; the variables that will act as site-level
#'   covariates, i.e. covariates that vary at the site level, for example,
#'   latitude/longitude or habitat predictors. If this parameter is missing, it
#'   will be assumed that any variable that is not an observation-level
#'   covariate (`obs_covs`) or the `site_id`, is a site-level covariate.
#' @param obs_covs character; the variables that will act as observation-level 
#'   covariates, i.e. covariates that vary within sites, at the level of 
#'   observations, for example, time or length of observation.
#'   
#' @details Hierarchical modeling requires repeat observations at each "site" to
#'   estimate detectability. A "site" is typically defined as a geographic
#'   location visited by the same observer within a period of temporal closure.
#'   To define these sites and filter out observations that do not correspond to
#'   repeat visits, users should use [filter_repeat_visits()], then pass the
#'   output to this function.
#'   
#'   [format_unmarked_occu()] is designed to prepare data to be converted into 
#'   an `unmarkedFrameOccu` object for occupancy modeling with 
#'   [unmarked::occu()]; however, it can also be used to prepare data for 
#'   conversion to an `unmarkedFramePCount` object for abundance modeling with 
#'   [unmarked::pcount()].
#'
#' @return A data frame that can be processed by [unmarked::formatWide()]. 
#'   Each row will correspond to a unqiue site and, assuming there are a maximum 
#'   of `N` observations per site, columns will be as follows:
#'   
#'   1. The unique site identifier, named "site".
#'   2. `N` response columns, one for each observation, named "y.1", ..., "y.N".
#'   3. Columns for each of the site-level covariates.
#'   4. Groups of `N` columns of observation-level covariates, one column per 
#'   covariate per observation, names "covariate_name.1", ..., 
#'   "covariate_name.N".
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
#' occ <- filter_repeat_visits(ebd_zf, n_days = 30)
#' # format for unmarked
#' # typically one would join in habitat covariates prior to this step
#' occ_wide <- format_unmarked_occu(occ,
#'                                  response = "species_observed",
#'                                  site_covs = c("latitude", "longitude"),
#'                                  obs_covs = c("effort_distance_km", 
#'                                               "duration_minutes"))
#' # create an unmarked object
#' if (requireNamespace("unmarked", quietly = TRUE)) {
#'   occ_um <- unmarked::formatWide(occ_wide, type = "unmarkedFrameOccu")
#'   unmarked::summary(occ_um)
#' }
#' 
#' # this function can also be used for abundance modeling
#' abd <- ebd_zf %>% 
#'   # convert count to integer, drop records with no count
#'   dplyr::mutate(observation_count = as.integer(observation_count)) %>% 
#'   dplyr::filter(!is.na(observation_count)) %>% 
#'   # filter to repeated visits
#'   filter_repeat_visits(n_days = 30)
#' # prepare for conversion to unmarkedFramePCount object
#' abd_wide <- format_unmarked_occu(abd,
#'                                  response = "observation_count",
#'                                  site_covs = c("latitude", "longitude"),
#'                                  obs_covs = c("effort_distance_km", 
#'                                               "duration_minutes"))
#' # create an unmarked object
#' if (requireNamespace("unmarked", quietly = TRUE)) {
#'   abd_um <- unmarked::formatWide(abd_wide, type = "unmarkedFrameOccu")
#'   unmarked::summary(abd_um)
#' }
format_unmarked_occu <- function(x, site_id = "site", 
                                 response = "species_observed",
                                 site_covs, obs_covs) {
  # checks
  stopifnot(is.data.frame(x))
  stopifnot(is.character(site_id), length(site_id) == 1,
            site_id %in% names(x), all(!is.na(x[[site_id]])))
  stopifnot(is.character(response), length(response) == 1,
            response %in% names(x))
  # observation covariates
  if (missing(obs_covs)) {
    obs_covs <- NULL
  } else {
    stopifnot(is.character(obs_covs), all(obs_covs %in% names(x)))
  }
  # site covariates
  if (missing(site_covs)) {
    site_covs <- setdiff(names(x), c(site_id, response, obs_covs))
  }
  if (length(site_covs) < 1) {
    stop("Must provide at least one site-level covariate")
  }
  
  # assign observation ids within sites
  x <- dplyr::group_by_at(x, site_id)
  x <- dplyr::mutate(x, .obs_id = dplyr::row_number())
  x <- dplyr::ungroup(x)
  
  # response to wide
  x_resp <- dplyr::select(x, !!rlang::sym(site_id), .data$.obs_id, 
                          !!rlang::sym(response))
  x_resp <- tidyr::spread(x_resp, .data$.obs_id, !!rlang::sym(response))
  names(x_resp)[-1] <- paste("y", names(x_resp)[-1], sep = ".")
  
  # site-level covariates
  x_site <- dplyr::select(x, !!rlang::sym(site_id), !!!rlang::syms(site_covs))
  # collapse to one row per site
  x_site <- dplyr::group_by_at(x_site, site_id)
  x_site <- dplyr::distinct(x_site)
  # check covariates are constant across site
  n_unique <- dplyr::count(dplyr::distinct(x_site))$n
  if (any(n_unique != 1)) {
    stop("Site-level covariates must be constant across sites")
  }
  x_site <- dplyr::ungroup(x_site)
  
  # observation-level covariates
  obs_covs_dfs <- list()
  for (vr in obs_covs) {
    # convert to wide
    x_obs <- dplyr::select(x, !!rlang::sym(site_id), .data$.obs_id, 
                           !!rlang::sym(vr))
    x_obs <- tidyr::spread(x_obs, .data$.obs_id, !!rlang::sym(vr))
    names(x_obs)[-1] <- paste(vr, names(x_obs)[-1], sep = ".")
    obs_covs_dfs[[vr]] <- x_obs
  }
  
  # combine everything together
  x_out <- dplyr::inner_join(x_resp, x_site, by = site_id)
  for (df in obs_covs_dfs) {
    x_out <- dplyr::left_join(x_out, df, by = site_id)
  }
  # rename site_id to "site" because required by unmarked
  names(x_out)[names(x_out) == site_id] <- "site"
  return(x_out)
}
