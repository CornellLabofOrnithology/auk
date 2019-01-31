library(dplyr)
context("unmarked utilities")

test_that("filter_repeat_visits works", {
  f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  ebd_zf <- auk_zerofill(x = f_ebd, sampling_events = f_smpl,
                         species = "Collared Kingfisher",
                         collapse = TRUE)
  occ <- filter_repeat_visits(ebd_zf, n_days = 30, min_obs = 2, max_obs = 10)
  
  expect_is(occ, "data.frame")
  expect_true(all(c("site", "closure_id", "n_observations") %in% names(occ)))
  expect_gte(min(occ$n_observations), 2)
  expect_lte(max(occ$n_observations), 10)
  
  # check closure period
  days_bt_first_last_obs <- occ %>% 
    group_by(site) %>% 
    mutate(drange = as.integer(diff(range(observation_date)))) %>% 
    pull(drange) %>% 
    max()
  expect_lte(days_bt_first_last_obs, 30)
  occ_10 <- filter_repeat_visits(ebd_zf, n_days = 10)
  days_bt_first_last_obs <- occ_10 %>% 
    group_by(site) %>% 
    mutate(drange = as.integer(diff(range(observation_date)))) %>% 
    pull(drange) %>% 
    max()
  expect_lte(days_bt_first_last_obs, 10)
})

test_that("format_unmarked works", {
  skip_if_not_installed("unmarked")
  f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  ebd_zf <- auk_zerofill(x = f_ebd, sampling_events = f_smpl,
                         species = "Collared Kingfisher",
                         collapse = TRUE)
  occ <- filter_repeat_visits(ebd_zf)
  occ_wide <- format_unmarked_occu(occ,
                                   response = "species_observed",
                                   site_covs = c("latitude", "longitude"),
                                   obs_covs = c("effort_distance_km",
                                                "duration_minutes"))
  occ_um <- unmarked::formatWide(occ_wide, type = "unmarkedFrameOccu")
  
  expect_is(occ_wide, "data.frame")
  expect_is(occ_um, "unmarkedFrameOccu")
  expect_named(occ_um@siteCovs, c("latitude", "longitude"))
  expect_named(occ_um@obsCovs, c("effort_distance_km", "duration_minutes"))
  expect_equal(nrow(occ_um@y), n_distinct(occ$site))
  expect_equal(nrow(occ_um@y), nrow(occ_wide))
})