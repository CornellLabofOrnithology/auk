context("auk_ebd")

test_that("auk_ebd refrence ebd file", {
  f <- system.file("extdata/ebd-sample.txt", package = "auk")
  ebd <- auk_ebd(f)

  filter_names <- c("species", "country", "extent", "date", "time",
                    "last_edited", "duration", "distance", "complete")

  expect_is(ebd, "auk_ebd")
  expect_equal(ebd$file, normalizePath(f))
  expect_equal(ebd$file, normalizePath(f))
  expect_null(ebd$file_sampling)
  expect_null(ebd$output)
  expect_null(ebd$output_sampling)
  expect_is(ebd$col_idx, "data.frame")
  expect_is(ebd$col_idx$index, "integer")
  expect_true(all(!is.na(ebd$col_idx$index)))
  expect_null(ebd$col_idx_sampling)
  expect_equal(names(ebd$filters), filter_names)
})

test_that("auk_ebd refrence ebd and sampling files", {
  f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  ebd <- auk_ebd(f_ebd, file_sampling = f_smpl)

  filter_names <- c("species", "country", "extent", "date", "time",
                    "last_edited", "duration", "distance", "complete")

  expect_is(ebd, "auk_ebd")
  expect_equal(ebd$file, normalizePath(f_ebd))
  expect_equal(ebd$file_sampling, normalizePath(f_smpl))
  expect_null(ebd$output)
  expect_null(ebd$output_sampling)
  expect_is(ebd$col_idx, "data.frame")
  expect_is(ebd$col_idx$index, "integer")
  expect_true(all(!is.na(ebd$col_idx$index)))
  expect_is(ebd$col_idx_sampling, "data.frame")
  expect_is(ebd$col_idx_sampling$index, "integer")
  expect_true(all(!is.na(ebd$col_idx_sampling$index)))
  expect_equal(names(ebd$filters), filter_names)
})

test_that("auk_ebd bad file references throws error", {
  expect_error(auk_ebd("AAAAAA"))
  expect_error(auk_ebd("AAAAAA", file_sampling = "BBBBBB"))
})

test_that("auk_ebd can't only have a sampling file", {
  f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  expect_error(auk_ebd(file_sampling = f_smpl))
})

test_that("auk_ebd incorrect separator throws error", {
  f <- system.file("extdata/ebd-sample.txt", package = "auk")
  expect_error(auk_ebd(f, sep = ","))
  expect_error(auk_ebd(f, sep = " "))
  expect_error(auk_ebd(f, sep = ",,,,,"))
})

test_that("auk_ebd prints method", {
  f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  ebd <- auk_ebd(f_ebd, file_sampling = f_smpl)

  expect_output(print(ebd), normalizePath(f_ebd), fixed = TRUE)
  expect_output(print(ebd), normalizePath(f_smpl), fixed = TRUE)
  expect_output(print(ebd), "Filters not executed")
  expect_output(print(ebd), "Complete checklists only: no")

  # now fake apply filters
  filters <- ebd %>%
    auk_species(species = c("Gray Jay", "Blue Jay")) %>%
    auk_country(country = c("US", "Canada")) %>%
    auk_extent(extent = c(-100, 37, -80, 52)) %>%
    auk_date(date = c("2012-01-01", "2012-12-31")) %>%
    auk_last_edited(date = c("2010-01-01", "2017-12-31")) %>%
    auk_time(start_time = c("06:00", "09:00")) %>%
    auk_duration(duration = c(0, 60)) %>%
    auk_complete()
  filters$output <- "output.txt"
  filters$output_sampling <- "output_sampling.txt"

  expect_output(print(filters), "output.txt", fixed = TRUE)
  expect_output(print(filters), "output_sampling.txt", fixed = TRUE)
  expect_output(print(filters), "Countries: CA, US")
  expect_output(print(filters), "Complete checklists only: yes")
})
