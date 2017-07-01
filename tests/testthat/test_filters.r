context("filter definition")

test_that("auk_species", {
  species <- c("Gray Jay", "Pluvialis squatarola")
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd() %>%
    auk_species(species)

  # works correctly
  expect_equal(ebd$filters$species,
               c("Perisoreus canadensis", "Pluvialis squatarola"))

  # add
  ebd <- auk_species(ebd, "blue jay")
  expect_equal(ebd$filters$species,
               c("Cyanocitta cristata", "Perisoreus canadensis",
                 "Pluvialis squatarola"))

  # no duplication
  ebd <- auk_species(ebd, rep(species, 2), replace = TRUE)
  expect_equal(ebd$filters$species,
               c("Perisoreus canadensis", "Pluvialis squatarola"))

  # overwrite
  ebd <- auk_species(ebd, "blue jay", replace = TRUE)
  expect_equal(ebd$filters$species, "Cyanocitta cristata")

  # raises error for bad species
  expect_error(auk_species(ebd, "bluejay"))
  expect_error(auk_species(ebd, ""))
  expect_error(auk_species(ebd, NA))
})

test_that("auk_country", {
  country <- c("CA", "United States", "mexico")
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd() %>%
    auk_country(country)

  # works correctly
  expect_equal(ebd$filters$country, c("CA", "MX", "US"))

  # add
  ebd <- auk_country(ebd, "Belize")
  expect_equal(ebd$filters$country, c("BZ", "CA", "MX", "US"))

  # no duplication
  ebd <- auk_country(ebd, rep(country, 2), replace = TRUE)
  expect_equal(ebd$filters$country, c("CA", "MX", "US"))

  # overwrite
  ebd <- auk_country(ebd, "Belize", replace = TRUE)
  expect_equal(ebd$filters$country, "BZ")

  # just code
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd() %>%
    auk_country("CA")
  expect_equal(ebd$filters$country, "CA")
  # just name
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd() %>%
    auk_country("Canada")
  expect_equal(ebd$filters$country, "CA")

  # raises error for bad countries
  expect_error(auk_country(ebd, "Atlantis"))
  expect_error(auk_country(ebd, "XX"))
  expect_error(auk_country(ebd, ""))
  expect_error(auk_country(ebd, NA))
})

test_that("auk_extent", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd()

  # works correctly
  e <- c(-125, 37, -120, 52)
  ebd <- auk_extent(ebd, e)
  expect_equal(ebd$filters$extent, e)

  # overwrite
  e <- c(0, 0, 1, 1)
  ebd <- auk_extent(ebd, e)
  expect_equal(ebd$filters$extent, e)

  # invalid lat
  expect_error(auk_extent(ebd, c(0, -91, 1, 1)))
  expect_error(auk_extent(ebd, c(0, -90, 1, 91)))
  expect_error(auk_extent(ebd, c(0, 1, 1, 0)))
  expect_error(auk_extent(ebd, c(0, 0, 1, 0)))
  # invalid lng
  expect_error(auk_extent(ebd, c(-181, 0, 1, 1)))
  expect_error(auk_extent(ebd, c(-180, 0, 181, 1)))
  expect_error(auk_extent(ebd, c(1, 0, 0, 1)))
  expect_error(auk_extent(ebd, c(0, 0, 0, 1)))
})

test_that("auk_date", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd()

  # character input
  d <- c("2015-01-01", "2015-12-31")
  ebd <- auk_date(ebd, d)
  expect_equal(ebd$filters$date, d)
  # date input
  ebd <- auk_date(ebd, as.Date(d))
  expect_equal(ebd$filters$date, d)

  # single day is ok
  d <- c("2015-01-01", "2015-01-01")
  ebd <- auk_date(ebd, d)
  expect_equal(ebd$filters$date, d)

  # overwrite
  d <- c("2010-01-01", "2010-12-31")
  ebd <- auk_date(ebd, d)
  expect_equal(ebd$filters$date, d)

  # invalid date format
  expect_error(auk_date(ebd, c("01-01-2015", "2015-12-31")))
  expect_error(auk_date(ebd, c("2015-00-01", "2015-12-31")))
  expect_error(auk_date(ebd, c("2015-01-32", "2015-12-31")))
  expect_error(auk_date(ebd, c("a", "b")))
  expect_error(auk_date(ebd, "2010-01-01"))

  # dates not sequential
  expect_error(auk_date(ebd, c("2015-12-31", "2015-01-01")))

})

test_that("auk_last_edited", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd()

  # character input
  d <- c("2015-01-01", "2015-12-31")
  ebd <- auk_last_edited(ebd, d)
  expect_equal(ebd$filters$last_edited, d)
  # date input
  ebd <- auk_last_edited(ebd, as.Date(d))
  expect_equal(ebd$filters$last_edited, d)

  # single day is ok
  d <- c("2015-01-01", "2015-01-01")
  ebd <- auk_last_edited(ebd, d)
  expect_equal(ebd$filters$last_edited, d)

  # overwrite
  d <- c("2010-01-01", "2010-12-31")
  ebd <- auk_last_edited(ebd, d)
  expect_equal(ebd$filters$last_edited, d)

  # invalid date format
  expect_error(auk_last_edited(ebd, c("01-01-2015", "2015-12-31")))
  expect_error(auk_last_edited(ebd, c("2015-00-01", "2015-12-31")))
  expect_error(auk_last_edited(ebd, c("2015-01-32", "2015-12-31")))
  expect_error(auk_last_edited(ebd, c("a", "b")))
  expect_error(auk_last_edited(ebd, "2010-01-01"))
  expect_error(auk_last_edited(ebd, "2015-01-01"))
  expect_error(auk_last_edited(ebd, c("2015-01-01", "2015-02-01",
                                      "2015-03-01")))

  # dates not sequential
  expect_error(auk_last_edited(ebd, c("2015-12-31", "2015-01-01")))

})

test_that("auk_time", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd()

  # works correctly
  t <- c("06:00", "08:00")
  ebd <- auk_time(ebd, t)
  expect_equal(ebd$filters$time, t)

  # overwrite
  t <- c("10:00", "12:00")
  ebd <- auk_time(ebd, t)
  expect_equal(ebd$filters$time, t)

  # invalid time format
  expect_error(auk_time(ebd, c("10:00AM", "12:00")))
  expect_error(auk_time(ebd, c("23:00", "25:00")))
  expect_error(auk_time(ebd, c("07:00", "08:61")))
  expect_error(auk_time(ebd, c("07.00", "08.00")))
  expect_error(auk_time(ebd, "07:00"))
  expect_error(auk_time(ebd, c("07:00", "08:00", "09:00")))
  expect_error(auk_time(ebd, c("a", "b")))

  # times not sequential
  expect_error(auk_time(ebd, c("08:00", "07:00")))
})

test_that("auk_duration", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd()

  # works correctly
  d <- c(0, 60)
  ebd <- auk_duration(ebd, d)
  expect_equal(ebd$filters$duration, d)

  # overwrite
  d <- c(60, 120)
  ebd <- auk_duration(ebd, d)
  expect_equal(ebd$filters$duration, d)

  # invalid duration format
  expect_error(auk_duration(ebd, c("0", "60")))
  expect_error(auk_duration(ebd, 0))
  expect_error(auk_duration(ebd, c(0, 60, 120)))
  expect_error(auk_duration(ebd, c(-10, 10)))

  # durations not sequential
  expect_error(auk_duration(ebd, c(60, 30)))
})

test_that("auk_complete", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd()

  # works correctly
  expect_equal(ebd$filters$complete, FALSE)
  ebd <- auk_complete(ebd)
  expect_equal(ebd$filters$complete, TRUE)
})
