context("ebird_species")

test_that("ebird_species mixing both scientific and common names", {
  expect_equal(ebird_species(c("Blackburnian Warbler", "Poecile atricapillus")),
               c("Setophaga fusca", "Poecile atricapillus"))
  expect_equal(ebird_species("Bornean Bristlehead"), "Pityriasis gymnocephala")
})

test_that("ebird_species not case sensitive", {
  expect_equal(ebird_species(c("blackburnian warbler", "poecile atricapillus")),
               c("Setophaga fusca", "Poecile atricapillus"))
  expect_equal(ebird_species("bornean bristlehead"), "Pityriasis gymnocephala")
})

test_that("ebird_species NA if not in taxonomy", {
  expect_equal(ebird_species("Homo sapiens"), NA_character_)
  expect_equal(ebird_species("blackburnianwarbler"), NA_character_)
  expect_equal(ebird_species("abcd"), NA_character_)
  expect_equal(ebird_species(""), NA_character_)
})

test_that("ebird_species return common names", {
  species <- c("Blackburnian Warbler", "Poecile atricapillus")
  expect_equal(ebird_species(species, scientific = FALSE),
               c("Blackburnian Warbler", "Black-capped Chickadee"))
  expect_equal(ebird_species("Pityriasis gymnocephala", scientific = FALSE),
               "Bornean Bristlehead")
})

test_that("ebird_species error for non-character argument", {
  expect_error(ebird_species(1:10))
  expect_error(ebird_species(TRUE))
})

test_that("ebird_species works for species with non-ascii characters", {
  expect_equal(ebird_species("Ruppell's Griffon"), "Gyps rueppelli")
  expect_equal(ebird_species("R\u00FCppell's Griffon"), "Gyps rueppelli")
})
