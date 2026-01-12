context("auk_keep_drop")

skip_on_cran()
skip_on_os("windows")

test_that("auk_filter correctly keeps all columns by default", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") |> 
    auk_ebd() |>
    auk_species(species = c("Canada Jay", "Blue Jay")) |> 
    auk_filter(file = tempfile()) |> 
    read_ebd(unique = FALSE, rollup = FALSE)
  expect_equal(ncol(ebd), 52)
})

test_that("auk_filter correctly keeps columns", {
  to_keep <- c("group_identifier", "sampling_event_identifier", 
               "observer_id",
               "scientific_name", "observation_count")
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") |> 
    auk_ebd() |>
    auk_species(species = c("Canada Jay", "Blue Jay")) |> 
    auk_filter(file = tempfile(), keep = to_keep) |> 
    read_ebd(unique = FALSE, rollup = FALSE)
  expect_equal(ncol(ebd), 5)
  expect_equal(names(ebd) |> sort(), to_keep |> sort())
})

test_that("auk_filter correctly drops columns", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") |> 
    auk_ebd() |>
    auk_species(species = c("Canada Jay", "Blue Jay")) |> 
    auk_filter(file = tempfile(), drop = "species comments") |> 
    read_ebd(unique = FALSE, rollup = FALSE)
  expect_equal(ncol(ebd), 51)
  expect_true(!"species_comments" %in% names(ebd))
})

test_that("auk_filter won't drop key columns", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") |> 
    auk_ebd() |>
    auk_species(species = c("Canada Jay", "Blue Jay"))
  expect_error(auk_filter(ebd, file = tempfile(), drop = "scientific_name"))
  expect_error(auk_filter(ebd, file = tempfile(), keep = "state"))
})

test_that("auk_filter correctly keeps sampling event data columns", {
  # set up filters
  f <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_smp <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  filters <- auk_ebd(f, f_smp) |>
    auk_species(species = "Collared Kingfisher") |>
    auk_time(start_time = c("06:00", "09:00")) |>
    auk_duration(duration = c(0, 60)) |>
    auk_complete()
  
  # run filters
  to_keep <- c("group_identifier", "sampling_event_identifier", 
               "observer_id",
               "scientific_name", "observation_count")
  tmp <- tempfile()
  tmp_smp <- tempfile()
  ebd <- auk_filter(filters, file = tmp, file_sampling = tmp_smp,
                    keep = to_keep)
  
  # read in results
  ebd_df <- read_ebd(ebd, rollup = FALSE)
  smp_df <- read_sampling(ebd)
  
  expect_equal(ncol(ebd_df), 6)
  expect_equal(ncol(smp_df), 4)
})
