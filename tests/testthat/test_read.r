context("read functions")

test_that("read_ebd reads an ebd file correctly", {
  f <- system.file("extdata/ebd-sample.txt", package = "auk")
  ebd <- auk_ebd(f)
  ebd$output <- f
  nm <- names(read_ebd(f))

  expect_is(read_ebd(f), "data.frame")
  expect_is(read_ebd(ebd), "data.frame")
  expect_equal(read_ebd(f), read_ebd(ebd))
  expect_lt(nrow(read_ebd(f)), nrow(read_ebd(f, unique = FALSE)))
  expect_true(all(grepl("^[_a-z]+$", nm)))
})

test_that("reads a sampling file correctly", {
  f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  ebd <- auk_ebd(f_ebd, file_sampling = f)
  ebd$output <- f_ebd
  ebd$output_sampling <- f
  nm <- names(read_sampling(f))
  
  # auk_sampling
  sampling <- auk_sampling(f)
  sampling$output <- f

  expect_is(read_sampling(f), "data.frame")
  expect_is(read_sampling(ebd), "data.frame")
  expect_is(read_sampling(sampling), "data.frame")
  expect_equal(read_sampling(f), read_sampling(ebd))
  expect_equal(read_sampling(f), read_sampling(sampling))
  expect_lt(nrow(read_sampling(f)), nrow(read_sampling(f, unique = FALSE)))
  expect_true(all(grepl("^[_a-z]+$", nm)))
})

test_that("read_ebd using different reader functions", {
  f <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  ebd_fr <- read_ebd(f, reader = "fread")
  ebd_rd <- read_ebd(f, reader = "readr")
  ebd_bs <- suppressWarnings(read_ebd(f, reader = "base"))

  expect_is(ebd_fr, "data.frame")
  expect_is(ebd_rd, "data.frame")
  expect_is(ebd_bs, "data.frame")

  expect_equal(nrow(ebd_fr), nrow(ebd_rd))
  expect_equal(nrow(ebd_rd), nrow(ebd_bs))
  expect_equal(ncol(ebd_fr), ncol(ebd_rd))
  expect_equal(ncol(ebd_rd), ncol(ebd_bs))

  expect_equal(ebd_fr[[1]], ebd_rd[[1]])
  expect_equal(ebd_rd[[1]], ebd_bs[[1]])

  expect_warning(read_ebd(f, reader = "base"))
})

test_that("read_ebd data frames identical for different read functions", {
  skip_on_os("windows")

  f <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  ebd_fr <- read_ebd(f, reader = "fread")
  ebd_rd <- read_ebd(f, reader = "readr")
  ebd_bs <- suppressWarnings(read_ebd(f, reader = "base"))

  expect_equal(ebd_fr$global_unique_identifier,
               ebd_rd$global_unique_identifier)
  expect_equal(ebd_rd$global_unique_identifier,
               ebd_bs$global_unique_identifier)
})

test_that("read_ebd throws errors for invalid separator", {
  f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_smp <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")

  expect_error(read_ebd(f_ebd, sep = ",,,"))
  expect_error(read_ebd(f_ebd, sep = " "))
})
