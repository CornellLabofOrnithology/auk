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
  expect_equal(
    sort(unique(ebd_ru$category)),
    c("hybrid", "slash", "species", "spuh")
  )
  dropped_cols <- c("subspecies_common_name", "subspecies_scientific_name")
  expect_true(all(dropped_cols %in% names(ebd)))
  expect_true(all(!dropped_cols %in% names(ebd_ru)))
})

test_that("auk_rollup drops domestic/feral taxa", {
  ebd <- system.file("extdata/ebd-rollup-ex.txt", package = "auk") |>
    read_ebd(rollup = FALSE)
  domestic <- ebd[ebd$category == "domestic", ]
  expect_gt(nrow(domestic), 0)
  # these checklists only reported the domestic form, with no co-occurring
  # wild-type record, so, unlike other sub-species categories, they should
  # disappear entirely rather than roll up to a "species" record

  # domestic taxa share their scientific name with the parent species, so
  # dropping them correctly relies on checking the category column, not just
  # matching names against the taxonomy
  ebd_ru <- auk_rollup(ebd)
  expect_false(any(domestic$checklist_id %in% ebd_ru$checklist_id))

  ebd_ru_higher <- auk_rollup(ebd, drop_higher = FALSE)
  expect_false(any(domestic$checklist_id %in% ebd_ru_higher$checklist_id))
})

test_that("auk_rollup preserves the unique attribute set by auk_unique()", {
  ebd <- system.file("extdata/ebd-rollup-ex.txt", package = "auk") |>
    read_ebd(rollup = FALSE)
  expect_true(isTRUE(attr(ebd, "unique")))

  ebd_ru <- auk_rollup(ebd)
  expect_true(isTRUE(attr(ebd_ru, "unique")))

  ebd_not_unique <- system.file("extdata/ebd-rollup-ex.txt", package = "auk") |>
    read_ebd(unique = FALSE, rollup = FALSE)
  ebd_ru2 <- auk_rollup(ebd_not_unique)
  expect_false(isTRUE(attr(ebd_ru2, "unique")))
})

test_that("auk_rollup rolls up correctly when every group is duplicated", {
  # exercises the branch where every checklist x species group has multiple
  # records (no singleton groups at all), unlike the other tests here
  df_test <- data.frame(
    checklist_id = rep(c("chk1", "chk2"), each = 2),
    scientific_name = rep("Setophaga coronata", 4),
    category = "issf",
    observation_count = c("3", "2", "1", "1"),
    stringsAsFactors = FALSE
  )
  result <- auk_rollup(df_test)

  expect_equal(nrow(result), 2)
  expect_equal(unique(result$category), "species")
  expect_equal(
    result$observation_count[result$checklist_id == "chk1"],
    "5"
  )
  expect_equal(
    result$observation_count[result$checklist_id == "chk2"],
    "2"
  )
})

test_that("auk_rollup keeps a non-numeric count as X for singleton groups", {
  df_test <- data.frame(
    checklist_id = "chk1",
    scientific_name = "Setophaga coronata",
    category = "species",
    observation_count = "X",
    stringsAsFactors = FALSE
  )
  result <- auk_rollup(df_test)
  expect_equal(result$observation_count, "X")
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
