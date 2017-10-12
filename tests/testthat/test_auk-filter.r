context("auk_filter")

test_that("auk_filter filter an ebd", {
  skip_on_cran()
  skip_on_os("windows")

  # set up filters
  f <- system.file("extdata/ebd-sample.txt", package = "auk")
  filters <- auk_ebd(f) %>%
    auk_species(species = c("Gray Jay", "Blue Jay")) %>%
    auk_country(country = c("US", "Canada")) %>%
    auk_extent(extent = c(-100, 37, -80, 52)) %>%
    auk_date(date = c("2012-01-01", "2012-12-31")) %>%
    auk_time(start_time = c("06:00", "09:00")) %>%
    auk_duration(duration = c(0, 60)) %>%
    auk_complete()
  # run filters
  tmp <- tempfile()
  ebd <- auk_filter(filters, file = tmp)

  expect_is(ebd, "auk_ebd")
  expect_equal(ebd$output, normalizePath(tmp))
  expect_null(ebd$output_sampling)

  # read in results
  ebd <- read_ebd(ebd)
  unlink(tmp)

  expect_is(ebd, "data.frame")
  expect_lt(nrow(ebd), nrow(read_ebd(f)))
  expect_equal(nrow(ebd), 12)
  expect_true(all(ebd$scientific_name %in% filters$filters$species))
  expect_true(all(ebd$country_code %in% filters$filters$country))
  expect_true(all(ebd$all_species_reported))
  expect_true(all(ebd$time_observations_started >= filters$filters$time[1]))
  expect_true(all(ebd$time_observations_started <= filters$filters$time[2]))
  expect_true(all(ebd$longitude >= filters$filters$extent[1]))
  expect_true(all(ebd$longitude <= filters$filters$extent[3]))
  expect_true(all(ebd$latitude >= filters$filters$extent[2]))
  expect_true(all(ebd$latitude <= filters$filters$extent[4]))
  
  # filter again
  tmp <- tempfile()
  ebd <- auk_ebd(f) %>%
    auk_project("EBIRD_CAN") %>% 
    auk_protocol("stationary") %>% 
    auk_filter(file = tmp) %>% 
    read_ebd()
  unlink(tmp)
  
  expect_true(all(ebd$project_code == "EBIRD_CAN"))
  expect_true(all(ebd$protocol_type == "eBird - Stationary Count"))
  
  # again
  ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk") %>% 
    auk_ebd() %>%
    auk_breeding() %>% 
    auk_filter(file = tmp) %>% 
    read_ebd()
  expect_true(all(!is.na(ebd$breeding_bird_atlas_code)))
})

test_that("auk_filter filter sampling and ebd files", {
  skip_on_cran()
  skip_on_os("windows")

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
  expect_equal(ebd$output, normalizePath(tmp))
  expect_equal(ebd$output_sampling, normalizePath(tmp_smp))

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
  skip_on_cran()
  skip_on_os("windows")

  # set up filters
  f <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_smp <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  f_tmp <- tempfile()
  ebd <- auk_ebd(f, f_smp) %>%
    auk_species(species = "Collared Kingfisher") %>%
    auk_filter(file = f_tmp, filter_sampling = FALSE)

  expect_equal(ebd$output, normalizePath(f_tmp))
  expect_null(ebd$output_sampling)

  unlink(f_tmp)
})

test_that("auk_filter won't overwrite files", {
  skip_on_cran()
  skip_on_os("windows")

  # set up filters
  f <- system.file("extdata/ebd-sample.txt", package = "auk")
  filters <- auk_ebd(f) %>%
    auk_species(species = c("Gray Jay", "Blue Jay"))

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
    auk_species(species = c("Gray Jay", "Blue Jay"))

  # run first time
  tmp <- tempfile()
  out <- auk_filter(filters, awk_file = tmp, execute = FALSE)

  expect_true(file.exists(out))
  expect_error(auk_filter(filters, execute = FALSE))
  expect_error(auk_filter(filters, awk_file = tmp))

  unlink(tmp)
})
