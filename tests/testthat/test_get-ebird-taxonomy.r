context("get_ebird_taxonomy")

test_that("get_ebird_taxonomy works", {
  skip_on_cran()
  
  tax <- get_ebird_taxonomy()
  nm <- c("scientific_name", "common_name", "species_code", "category", 
          "taxon_order", "order", "family", "report_as")
  
  expect_is(tax, "data.frame")
  expect_named(tax, nm)
  expect_is(tax$scientific_name, "character")
  expect_is(tax$species_code, "character")
  expect_true("Canada Jay" %in% tax$common_name)
})

test_that("get_ebird_taxonomy locale works", {
  skip_on_cran()
  
  tax_es <- get_ebird_taxonomy(locale = "es")
  
  expect_is(tax_es, "data.frame")
  expect_is(tax_es$scientific_name, "character")
  expect_is(tax_es$species_code, "character")
  expect_true("Arrendajo canadiense" %in% tax_es$common_name)
  expect_false("Canada Jay" %in% tax_es$common_name)
})

test_that("get_ebird_taxonomy version works", {
  skip_on_cran()
  
  tax_2016 <- get_ebird_taxonomy(version = 2016)
  tax_2018 <- get_ebird_taxonomy(version = 2018)
  expect_is(tax_2016, "data.frame")
  expect_is(tax_2016$scientific_name, "character")
  expect_is(tax_2016$species_code, "character")
  expect_false("whiant1" %in% tax_2016$species_code)
  expect_true("whiant1" %in% tax_2018$species_code)
})

test_that("get_ebird_taxonomy error handling", {
  skip_on_cran()
  
  expect_error(get_ebird_taxonomy(version = "abcd"))
  expect_error(get_ebird_taxonomy(version = 2010))
  expect_error(get_ebird_taxonomy(locale = 27))
  expect_error(get_ebird_taxonomy(locale = c("es", "en")))
})