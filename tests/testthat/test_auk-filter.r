context("auk_filter")

skip_on_cran()
skip_on_os("windows")

test_that("auk_filter filter an ebd", {
  # set up filters
  f <- system.file("extdata/ebd-sample.txt", package = "auk")
  filters <- auk_ebd(f) %>%
    auk_species(species = c("Canada Jay", "Blue Jay")) %>%
    auk_country(country = c("US", "Canada")) %>%
    auk_bbox(bbox = c(-100, 37, -80, 52)) %>%
    auk_date(date = c("2012-01-01", "2012-12-31")) %>%
    auk_time(start_time = c("06:00", "09:00")) %>%
    auk_duration(duration = c(0, 120)) %>%
    auk_complete()
  # run filters
  tmp <- tempfile()
  ebd <- auk_filter(filters, file = tmp)

  expect_is(ebd, "auk_ebd")
  expect_equal(ebd$output, normalizePath(tmp, winslash = "/"))
  expect_null(ebd$output_sampling)

  # read in results
  ebd <- read_ebd(ebd)
  unlink(tmp)

  expect_is(ebd, "data.frame")
  expect_lt(nrow(ebd), nrow(read_ebd(f)))
  expect_gt(nrow(ebd), 1)
  expect_true(all(ebd$scientific_name %in% filters$filters$species))
  expect_true(all(ebd$country_code %in% filters$filters$country))
  expect_true(all(ebd$all_species_reported))
  expect_true(all(ebd$time_observations_started >= filters$filters$time[1]))
  expect_true(all(ebd$time_observations_started <= filters$filters$time[2]))
  expect_true(all(ebd$longitude >= filters$filters$bbox[1]))
  expect_true(all(ebd$longitude <= filters$filters$bbox[3]))
  expect_true(all(ebd$latitude >= filters$filters$bbox[2]))
  expect_true(all(ebd$latitude <= filters$filters$bbox[4]))
  
  # filter again
  tmp <- tempfile()
  ebd <- auk_ebd(f) %>%
    auk_project("EBIRD_CAN") %>% 
    auk_protocol("Traveling") %>% 
    auk_state("CA-ON") %>% 
    auk_filter(file = tmp) %>% 
    read_ebd()
  unlink(tmp)
  
  expect_true(all(ebd$project_code == "EBIRD_CAN"))
  expect_true(all(ebd$protocol_type == "Traveling"))
  expect_true(all(ebd$state_code == "CA-ON"))
  
  # again
  ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk") %>% 
    auk_ebd() %>%
    auk_breeding() %>% 
    auk_filter(file = tmp) %>% 
    read_ebd()
  expect_true(all(!is.na(ebd$breeding_bird_atlas_code)))
})

test_that("auk_filter filter sampling and ebd files", {
  # set up filters
  f <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_smp <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  filters <- auk_ebd(f, f_smp) %>%
    auk_species(species = "Collared Kingfisher") %>%
    auk_time(start_time = c("06:00", "09:00")) %>%
    auk_duration(duration = c(0, 60)) %>%
    auk_complete()
  # run filters
  tmp <- tempfile()
  tmp_smp <- tempfile()
  ebd <- auk_filter(filters, file = tmp, file_sampling = tmp_smp)

  expect_is(ebd, "auk_ebd")
  expect_equal(ebd$output, normalizePath(tmp, winslash = "/"))
  expect_equal(ebd$output_sampling,
               normalizePath(tmp_smp, winslash = "/"))

  # read in results
  ebd_df <- read_ebd(ebd)
  smp_df <- read_sampling(ebd)
  unlink(tmp)
  unlink(tmp_smp)

  expect_is(ebd_df, "data.frame")
  expect_is(smp_df, "data.frame")
  expect_lt(nrow(ebd_df), nrow(read_ebd(f)))
  expect_true(all(smp_df$all_species_reported))
  expect_true(all(smp_df$duration_minutes >= filters$filters$duration[1]))
  expect_true(all(smp_df$duration_minutes <= filters$filters$duration[2]))
})

test_that("auk_filter turn off filtering of sampling event data", {
  # set up filters
  f <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_smp <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  f_tmp <- tempfile()
  ebd <- auk_ebd(f, f_smp) %>%
    auk_species(species = "Collared Kingfisher") %>%
    auk_filter(file = f_tmp, filter_sampling = FALSE)

  expect_equal(ebd$output, normalizePath(f_tmp, winslash = "/"))
  expect_null(ebd$output_sampling)

  unlink(f_tmp)
})

test_that("auk_filter won't overwrite files", {
  # set up filters
  f <- system.file("extdata/ebd-sample.txt", package = "auk")
  filters <- auk_ebd(f) %>%
    auk_species(species = c("Canada Jay", "Blue Jay"))

  # run first time
  tmp <- tempfile()
  out <- auk_filter(filters, file = tmp)

  expect_error(auk_filter(filters, file = tmp))
  expect_is(auk_filter(filters, file = tmp, overwrite = TRUE), "auk_ebd")

  unlink(tmp)
})

test_that("auk_filter can save awk file on any system", {
  # set up filters
  f <- system.file("extdata/ebd-sample.txt", package = "auk")
  filters <- auk_ebd(f) %>%
    auk_species(species = c("Canada Jay", "Blue Jay"))

  # run first time
  tmp <- tempfile()
  out <- auk_filter(filters, awk_file = tmp, execute = FALSE)

  expect_true(file.exists(out))
  expect_error(auk_filter(filters, execute = FALSE))
  expect_error(auk_filter(filters, awk_file = tmp))

  unlink(tmp)
})

test_that("auk_filter filter an auk_sampling object", {
  # set up filters
  f <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  filters <- auk_sampling(f) %>%
    auk_time(start_time = c("06:00", "09:00")) %>%
    auk_duration(duration = c(0, 60)) %>%
    auk_complete()
  # run filters
  tmp <- tempfile()
  sampling <- auk_filter(filters, file = tmp)
  
  expect_is(sampling, "auk_sampling")
  expect_equal(sampling$output, normalizePath(tmp, winslash = "/"))
  
  # read in results
  s_df <- read_sampling(sampling)
  unlink(tmp)
  
  expect_is(s_df, "data.frame")
  expect_lt(nrow(s_df), nrow(read_sampling(f)))
  expect_equal(nrow(s_df), 19)
  expect_true(all(s_df$time_observations_started >= filters$filters$time[1]))
  expect_true(all(s_df$time_observations_started <= filters$filters$time[2]))
  expect_true(all(s_df$duration_minutes >= filters$filters$duration[1]))
  expect_true(all(s_df$duration_minutes <= filters$filters$duration[2]))
})

test_that("auk_filter works with wildcard dates", {
  # set up filters
  f <- system.file("extdata/ebd-sample.txt", package = "auk")
  tmp <- tempfile()
  filters <- auk_ebd(f) %>%
    auk_date(date = c("*-05-01", "*-06-30"))
  ebd <- auk_filter(filters, file = tmp) %>% 
    read_ebd()
  unlink(tmp)
  
  expect_is(ebd, "data.frame")
  expect_lt(nrow(ebd), nrow(read_ebd(f)))
  expect_gt(nrow(ebd), 0)
  month_day <- as.Date(ebd$observation_date) %>% 
    format("%m-%d")
  md_range <- sub("*-", "", filters$filters$date, fixed = TRUE)
  expect_true(all(month_day >= md_range[1]))
  expect_true(all(month_day <= md_range[2]))
})