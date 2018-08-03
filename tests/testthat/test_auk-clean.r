context("auk_clean")

test_that("auk_clean cleans out unreadable records", {
  skip_on_cran()
  #skip_on_os("windows")

  f <- system.file("extdata/ebd-sample_messy.txt", package = "auk")
  tmp <- tempfile()

  # clean file to remove problem rows
  cleaned <- auk_clean(f, tmp)

  expect_warning(read_ebd(f))
  expect_is(read_ebd(cleaned), "data.frame")
  expect_lt(length(readLines(cleaned)), length(readLines(f)))
  expect_equal(ncol(read.delim(f, nrows = 5, quote = "")),
               ncol(read.delim(cleaned, nrows = 5, quote = "")) + 1)

  unlink(tmp)
})

test_that("auk_clean throws error for bad input", {
  skip_on_cran()
  #skip_on_os("windows")

  f <- system.file("extdata/ebd-sample_messy.txt", package = "auk")
  tmp <- tempfile()
  tmp_with_no_dir <- file.path(tempdir(), "asdfghjkl", "out.txt")

  expect_error(auk_clean("asdfghjkl", tmp))
  expect_error(auk_clean(f, tmp_with_no_dir))
  expect_error(auk_clean(f, tmp, sep = ","))
  expect_error(auk_clean(f, tmp, sep = "\t\t"))

  unlink(tmp)
  unlink(tmp_with_no_dir)
})

test_that("auk_clean won't overwrite an existing file", {
  skip_on_cran()
  #skip_on_os("windows")

  f <- system.file("extdata/ebd-sample_messy.txt", package = "auk")
  tmp <- tempfile()
  cleaned <- auk_clean(f, tmp)

  expect_error(auk_clean(f, tmp))
  expect_equal(auk_clean(f, tmp, overwrite = TRUE), normalizePath(tmp))

  unlink(tmp)
})
