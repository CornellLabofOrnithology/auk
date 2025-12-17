context("auk_ebd_version")

test_that("auk_ebd_version works", {
  file <- "ebd_relAug-2018.txt"
  ver <- auk_ebd_version(file, check_exists = FALSE)
  expect_equal(ver$ebd_version, as.Date("2018-08-01", "%Y-%m-%d"))
  expect_equal(ver$taxonomy_version, 2018)
  
  file <- "ebd_relMay-2016.txt"
  ver <- auk_ebd_version(file, check_exists = FALSE)
  expect_equal(ver$ebd_version, as.Date("2016-05-01", "%Y-%m-%d"))
  expect_equal(ver$taxonomy_version, 2015)
})

test_that("auk_ebd_version works on objects", {
  # auk_ebd object
  f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_cl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  ebd <- auk_ebd(f_ebd)
  sed <- auk_sampling(f_cl)
  ebd$file <- "ebd_relAug-2018.txt"
  sed$file <- "ebd_relAug-2018.txt"
  
  ver <- auk_ebd_version(ebd, check_exists = FALSE)
  expect_equal(ver$ebd_version, as.Date("2018-08-01", "%Y-%m-%d"))
  expect_equal(ver$taxonomy_version, 2018)
  
  ver <- auk_ebd_version(sed, check_exists = FALSE)
  expect_equal(ver$ebd_version, as.Date("2018-08-01", "%Y-%m-%d"))
  expect_equal(ver$taxonomy_version, 2018)
})

test_that("auk_ebd_version fails correctly", {
  # file doesn't exist
  expect_error(auk_ebd_version(tempfile()))
  # no date to extract
  ver <- auk_ebd_version("ebd_relXyz-2018.txt", check_exists = FALSE)
  expect_equal(ver$ebd_version, NA)
  expect_equal(ver$taxonomy_version, NA)
})
