context("auk_zerofill")

test_that("auk_zerofill zerofill works normally", {
  f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  zf <- auk_zerofill(x = f_ebd, sampling_events = f_smpl)

  expect_is(zf, "auk_zerofill")
  expect_is(zf$observations, "data.frame")
  expect_is(zf$sampling_events, "data.frame")

  expect_named(zf$observations,
               c("checklist_id", "scientific_name",
                 "breeding_code", "breeding_category", 
                 "behavior_code", "age_sex",
                 "observation_count", "species_observed"))
  expect_equal(
    anyDuplicated(zf$observations[, c("checklist_id", "scientific_name")]),
    0)
})

test_that("auk_zerofill input types", {
  f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  ebd <- auk_ebd(f_ebd, f_smpl) |>
    auk_complete()
  ebd$output <- f_ebd
  ebd$output_sampling <- f_smpl

  zf_f <- auk_zerofill(f_ebd, f_smpl)
  zf_ebd <- auk_zerofill(ebd)
  zf_df <- auk_zerofill(read_ebd(f_ebd), read_sampling(f_smpl))

  expect_equal(zf_f, zf_ebd)
  expect_equal(zf_ebd, zf_df)
})

test_that("auk_zerofill subset by species", {
  f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  zf <- auk_zerofill(x = f_ebd, sampling_events = f_smpl,
                     species = "Collared Kingfisher")

  expect_true(all(zf$observations$scientific_name == "Todiramphus chloris"))
  expect_equal(anyDuplicated(zf$observations[, "checklist_id"]), 0)
})


test_that("auk_zerofill return a data frame", {
  f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  zf <- auk_zerofill(x = f_ebd, sampling_events = f_smpl, collapse = TRUE)

  expect_is(zf, "data.frame")
  expect_equal(
    anyDuplicated(zf[, c("checklist_id", "scientific_name")]),
    0)
})

test_that("collapse_zerofill converts an auk_zerofill object to df", {
  f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  zf <- auk_zerofill(x = f_ebd, sampling_events = f_smpl)

  expect_is(collapse_zerofill(zf), "data.frame")
})

test_that("auk_zerofill prints method", {
  f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  zf <- auk_zerofill(x = f_ebd, sampling_events = f_smpl)

  p_format <- "Zero-filled EBD: [,0-9]+ unique checklists, for [0-9]+ species."
  expect_output(print(zf), p_format)
})

test_that("auk_zerofill error is auk_unique() hasn't been run", {
  f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  zf <- auk_zerofill(x = f_ebd, sampling_events = f_smpl)

  ebd <- read_ebd(f_ebd, unique = FALSE)
  smp <- read_sampling(f_smpl, unique = FALSE)
  expect_error(auk_zerofill(ebd, smp, unique = FALSE))
  ebd <- auk_unique(ebd)
  expect_error(auk_zerofill(ebd, smp, unique = FALSE))
})

test_that("auk_zerofill lack of complete checklists throws error", {
  f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  ebd <- read_ebd(f_ebd)
  smpl <- read_sampling(f_smpl)
  smpl$all_species_reported[sample(seq_len(nrow(smpl)), 3)] <- FALSE
  expect_error(auk_zerofill(ebd, smpl))
  expect_warning(auk_zerofill(ebd, smpl, complete = FALSE))
})

test_that("auk_zerofill throws errors with bad input data", {
  f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
  f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
  ebd <- auk_ebd(f_ebd, f_smpl) |>
    auk_complete()

  expect_error(auk_zerofill(ebd))
  ebd$output <- f_ebd
  expect_error(auk_zerofill(ebd))
  ebd$output_sampling <- f_smpl

  expect_error(auk_zerofill(ebd, species = "asdf"))
  expect_error(auk_zerofill(ebd, species = "Blue Jay"))
  expect_warning(auk_zerofill(ebd, species = c("Collared Kingfisher",
                                               "Blue Jay")))
})
