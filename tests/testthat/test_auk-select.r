context("auk_select")

test_that("auk_select works on ebd", {
  skip_on_cran()
  
  # columns
  cols <- c("latitude", "LONGITUDE",
            "group_identifier", "sampling event identifier",
            "scientific name", "observation count")
  f <- system.file("extdata/ebd-sample.txt", package = "auk")
  tmp <- tempfile()
  ebd <- auk_ebd(f) %>% 
    auk_select(select = cols, file = tmp) %>% 
    read_ebd(unique = FALSE)
  unlink(tmp)
  
  expect_is(ebd, "data.frame")
  expect_equal(ncol(ebd), length(cols))
  
  # raise an error
  cols <- "wrong column name"
  tmp <- tempfile()
  expect_error(auk_ebd(f) %>% auk_select(select = cols, file = tmp))
  unlink(tmp)
})

test_that("auk_select works on sampling events", {
  skip_on_cran()
  
  # columns
  cols <- c("latitude", "LONGITUDE",
            "group_identifier", "sampling event identifier")
  f <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  tmp <- tempfile()
  sampling <- auk_sampling(f) %>% 
    auk_select(select = cols, file = tmp) %>% 
    read_sampling(unique = FALSE)
  unlink(tmp)
  
  expect_is(sampling, "data.frame")
  expect_equal(ncol(sampling), length(cols))
  
  # raise an error
  cols <- "wrong column name"
  tmp <- tempfile()
  expect_error(auk_sampling(f) %>% auk_select(select = cols, file = tmp))
  unlink(tmp)
})