context("auk_split")
library(dplyr)

skip_on_cran()
skip_on_os("windows")

test_that("auk_split splits correctly", {
  # split into two species files
  species <- c("Perisoreus canadensis", "Cyanocitta cristata")
  prefix <- file.path(tempdir(), "ebd_")
  f <- system.file("extdata/ebd-sample.txt", package = "auk") |>
    auk_split(species = species, prefix = prefix, overwrite = TRUE)
  
  # check
  for (i in seq_along(species)) {
    ebd <- read_ebd(f[i])
    ebd_full <- system.file("extdata/ebd-sample.txt", package = "auk") |> 
      read_ebd() |> 
      filter(scientific_name == species[i])
    expect_is(ebd, "data.frame")
    expect_true(all(ebd$scientific_name == species[i]))
    expect_equal(nrow(ebd), nrow(ebd_full))
  }
  
  unlink(list.files(dirname(prefix), basename(prefix), full.names = TRUE))
})

test_that("auk_split throws error for bad input", {
  species <- c("Perisoreus canadensis", "Cyanocitta stelleri")
  prefix <- file.path(tempdir(), "ebd_")
  f <- system.file("extdata/ebd-sample.txt", package = "auk")
  prefix_with_no_dir <- file.path(tempdir(), "asdfghjkl", "ebd_")
  
  expect_error(auk_split("asdfghjkl", species))
  expect_error(auk_split(f, species, prefix = prefix_with_no_dir))
  expect_error(auk_split(f, species = "xxxxx"))
  expect_error(auk_split(f, species = character()))
  expect_error(auk_split(f, species, sep = "\t\t"))
  expect_error(auk_split(f, species, sep = "\t\t"))
})

test_that("auk_split won't overwrite an existing file", {
  # split into two species files
  species <- c("Perisoreus canadensis", "Cyanocitta stelleri")
  prefix <- file.path(tempdir(), "ebd_")
  f <- system.file("extdata/ebd-sample.txt", package = "auk")
  auk_split(f, species = species, prefix = prefix)
  # again
  expect_error(auk_split(f, species = species, prefix = prefix))
  
  unlink(list.files(dirname(prefix), basename(prefix), full.names = TRUE))
})
