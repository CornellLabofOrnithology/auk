context("auk_rollup")

test_that("auk_filter rolls up to species level", {
  ebd <- system.file("extdata/ebd-rollup-ex.txt", package = "auk") %>%
    read_ebd(rollup = FALSE)
  ebd_ru <- auk_rollup(ebd)
  
  expect_lt(nrow(ebd_ru), nrow(ebd))
  vars <- c("checklist_id", "scientific_name")
  expect_gt(anyDuplicated(ebd[, vars]), 0)
  expect_equal(anyDuplicated(ebd_ru[, vars]), 0)
})

test_that("auk_filter works with unique = FALSE", {
  ebd <- system.file("extdata/ebd-rollup-ex.txt", package = "auk") %>%
    read_ebd(unique = FALSE, rollup = FALSE)
  ebd_ru <- auk_rollup(ebd)
  
  expect_lt(nrow(ebd_ru), nrow(ebd))
  vars <- c("sampling_event_identifier", "scientific_name")
  expect_gt(anyDuplicated(ebd[, vars]), 0)
  expect_equal(anyDuplicated(ebd_ru[, vars]), 0)
})
