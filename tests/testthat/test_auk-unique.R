context("auk_unique")
library(dplyr)

test_that("auk_unique removes duplicates", {
  ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk") |>
    read_ebd(unique = FALSE)
  ebd_unique <- auk_unique(ebd)

  ebd_g <- ebd[!is.na(ebd$group_identifier), ]
  ebd_unique_g <- ebd_unique[!is.na(ebd_unique$group_identifier), ]

  unique_cols <- c("scientific_name", "group_identifier")

  expect_lt(nrow(ebd_unique), nrow(ebd))
  expect_equal(ncol(ebd_unique), ncol(ebd) + 2)
  expect_true(!"checklist_id" %in% names(ebd))
  expect_true("checklist_id" %in% names(ebd_unique))
  expect_gt(anyDuplicated(ebd_g[, unique_cols]), 0)
  expect_equal(anyDuplicated(ebd_unique_g[, unique_cols]), 0)
  expect_equal(class(ebd), class(ebd_unique))
})

test_that("auk_unique removes duplicates in sampling file", {
  ebd <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") |>
    read_sampling(unique = FALSE)
  ebd_unique <- auk_unique(ebd, checklists_only = TRUE)

  ebd_g <- ebd[!is.na(ebd$group_identifier), ]
  ebd_unique_g <- ebd_unique[!is.na(ebd_unique$group_identifier), ]

  unique_cols <- "group_identifier"

  expect_lt(nrow(ebd_unique), nrow(ebd))
  expect_equal(ncol(ebd_unique), ncol(ebd) + 2)
  expect_true(!"checklist_id" %in% names(ebd))
  expect_true("checklist_id" %in% names(ebd_unique))
  expect_gt(anyDuplicated(ebd_g[, unique_cols]), 0)
  expect_equal(anyDuplicated(ebd_unique_g[, unique_cols]), 0)
  expect_equal(class(ebd), class(ebd_unique))
})

test_that("auk_unique combines ids correctly", {
  ebd <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") |>
    read_sampling(unique = FALSE)
  ebd_unique <- auk_unique(ebd, checklists_only = TRUE)

  ebd_g <- ebd |>
    filter(!is.na(group_identifier)) |>
    group_by(group_identifier) |>
    arrange(sampling_event_identifier) |>
    summarize(
      cid = paste(sampling_event_identifier, collapse = ","),
      oid = paste(observer_id, collapse = ",")
    ) |>
    inner_join(ebd_unique, by = "group_identifier")

  expect_equal(ebd_g$cid, ebd_g$sampling_event_identifier)
  expect_equal(ebd_g$oid, ebd_g$observer_id)
})

test_that("auk_unique retains the union of species across group members", {
  # obsr1 reports sp1 and sp2, obsr2 reports sp2 and sp3 on the same checklist
  x <- data.frame(
    group_identifier = c("G1", "G1", "G1", "G1"),
    sampling_event_identifier = c("S1", "S1", "S2", "S2"),
    scientific_name = c("sp1", "sp2", "sp2", "sp3"),
    observer_id = c("obsr1", "obsr1", "obsr2", "obsr2"),
    duration_minutes = c(30, 30, 30, 30),
    stringsAsFactors = FALSE
  )
  x_unique <- auk_unique(x)

  expect_equal(nrow(x_unique), 3)
  expect_setequal(x_unique$scientific_name, c("sp1", "sp2", "sp3"))
  # sp2, reported by both members, is deduplicated to the lowest checklist id
  sp2 <- x_unique[x_unique$scientific_name == "sp2", ]
  expect_equal(sp2$checklist_id, "G1")
  expect_equal(sp2$observer_id, "obsr1,obsr2")
})

test_that("auk_unique detects effort disagreement", {
  x <- data.frame(
    group_identifier = c("G1", "G1", "G2", "G2", NA),
    sampling_event_identifier = c("S1", "S2", "S3", "S4", "S5"),
    scientific_name = c("sp1", "sp1", "sp1", "sp1", "sp1"),
    observer_id = c("obsr1", "obsr2", "obsr3", "obsr4", "obsr5"),
    duration_minutes = c(30, 30, 30, 45, 60),
    effort_distance_km = c(1, 1, 1, 1, 2),
    protocol_type = c(
      "Traveling",
      "Traveling",
      "Traveling",
      "Traveling",
      "Stationary"
    ),
    all_species_reported = c(TRUE, TRUE, TRUE, TRUE, TRUE),
    stringsAsFactors = FALSE
  )

  x_unique <- auk_unique(x)
  disagreement_by_id <- function(x, id) {
    x$effort_disagreement[x$checklist_id == id]
  }
  # G1 agrees on all effort fields, G2 disagrees on duration_minutes, and the
  # non-group checklist S5 trivially has no disagreement
  expect_false(disagreement_by_id(x_unique, "G1"))
  expect_true(disagreement_by_id(x_unique, "G2"))
  expect_false(disagreement_by_id(x_unique, "S5"))
  # disagreement doesn't change which value is kept: still the lowest id
  expect_equal(x_unique$duration_minutes[x_unique$checklist_id == "G2"], 30)

  # only columns actually present in x are checked
  x_unique_restricted <- auk_unique(x, effort_cols = "protocol_type")
  expect_false(disagreement_by_id(x_unique_restricted, "G2"))
})

test_that("auk_unique throws error for invalid input", {
  ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk") |>
    read_ebd(unique = FALSE)
  sed <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") |>
    read_sampling(unique = FALSE)

  expect_error(auk_unique(sed))
  expect_error(auk_unique(ebd, group_id = "abc"))
  expect_error(auk_unique(ebd, checklist_id = "abc"))
  expect_error(auk_unique(ebd, species_id = "abc"))
  expect_error(auk_unique(ebd, observer_id = "abc"))
})
