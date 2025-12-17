context("auk_rollup")

test_that("auk_rollup rolls up to species level", {
  ebd <- system.file("extdata/ebd-rollup-ex.txt", package = "auk") |>
    read_ebd(rollup = FALSE)
  ebd_ru <- auk_rollup(ebd)
  
  expect_lt(nrow(ebd_ru), nrow(ebd))
  vars <- c("checklist_id", "scientific_name")
  expect_gt(anyDuplicated(ebd[, vars]), 0)
  expect_equal(anyDuplicated(ebd_ru[, vars]), 0)
  expect_equal(unique(ebd_ru$category), "species")
  dropped_cols <- c("subspecies_common_name", "subspecies_scientific_name")
  expect_true(all(dropped_cols %in% names(ebd)))
  expect_true(all(!dropped_cols %in% names(ebd_ru)))
})

test_that("auk_rollup works with unique = FALSE", {
  ebd <- system.file("extdata/ebd-rollup-ex.txt", package = "auk") |>
    read_ebd(unique = FALSE, rollup = FALSE)
  ebd_ru <- auk_rollup(ebd)
  
  expect_lt(nrow(ebd_ru), nrow(ebd))
  vars <- c("sampling_event_identifier", "scientific_name")
  expect_gt(anyDuplicated(ebd[, vars]), 0)
  expect_equal(anyDuplicated(ebd_ru[, vars]), 0)
  expect_equal(unique(ebd_ru$category), "species")
  dropped_cols <- c("subspecies_common_name", "subspecies_scientific_name")
  expect_true(all(dropped_cols %in% names(ebd)))
  expect_true(all(!dropped_cols %in% names(ebd_ru)))
})

test_that("auk_rollup keeps higher taxa", {
  ebd <- system.file("extdata/ebd-rollup-ex.txt", package = "auk") |>
    read_ebd(rollup = FALSE)
  ebd_ru <- auk_rollup(ebd, drop_higher = FALSE)
  
  expect_lt(nrow(ebd_ru), nrow(ebd))
  vars <- c("checklist_id", "scientific_name")
  expect_gt(anyDuplicated(ebd[, vars]), 0)
  expect_equal(anyDuplicated(ebd_ru[, vars]), 0)
  expect_equal(sort(unique(ebd_ru$category)), 
               c("hybrid", "slash", "species", "spuh"))
  dropped_cols <- c("subspecies_common_name", "subspecies_scientific_name")
  expect_true(all(dropped_cols %in% names(ebd)))
  expect_true(all(!dropped_cols %in% names(ebd_ru)))
})

test_that("auk_rollup warns when species are removed", {
  df_test <- data.frame(
    checklist_id = c("chk1", "chk2"),
    scientific_name = c("Spinus psaltria", "Jiggetus bubingai"),
    category = c("species", "species"),
    observation_count = c(10, 5)
  )
  
  # Expect a warning when running auk_rollup
  expect_warning(
    df_result <- auk_rollup(df_test),
    regexp = "Removed the following species due to invalid taxonomy"
  )

  # Ensure the unknown species was removed
  expect_false("Jiggetus bubingai" %in% df_result$scientific_name)

  # Ensure Lesser Goldfinch remains in the dataset
  expect_true("Spinus psaltria" %in% df_result$scientific_name)
})
