context("filter definition")

skip_on_cran()

test_that("auk_species", {
  species <- c("Canada Jay", "Pluvialis squatarola")
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
  
  # taxonomy versions
  skip_if_offline()
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd()
  ebd$file <- "ebd_relAug-2016.txt"
  expect_warning(auk_species(ebd, "Canada Jay"))
  # assuming ebird api is accessible, using 2016 taxonomy should work
  res <- tryCatch(auk_species(ebd, "Canada Jay", taxonomy_version = 2016), 
                  error = function(e) e)
  if (!inherits(res, "error")) {
    expect_s3_class(res, "auk_ebd")
  }
})

test_that("auk_country", {
  country <- c("CA", "United States", "mexico", "kosovo", "AC")
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd() %>%
    auk_country(country)
  
  # works correctly
  expect_equal(ebd$filters$country, c("AC", "CA", "MX", "US", "XK"))
  
  # add
  ebd <- auk_country(ebd, "Belize")
  expect_equal(ebd$filters$country, c("AC", "BZ", "CA", "MX", "US", "XK"))
  
  # no duplication
  ebd <- auk_country(ebd, rep(country, 2), replace = TRUE)
  expect_equal(ebd$filters$country, c("AC", "CA", "MX", "US", "XK"))
  
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
  expect_error(auk_country(ebd, "AA"))
  expect_error(auk_country(ebd, ""))
  expect_error(auk_country(ebd, NA))
})

test_that("auk_state", {
  state <- c("CR-P", "US-TX")
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd() %>%
    auk_state(state)
  
  # works correctly
  expect_equal(ebd$filters$state, state)
  
  # add
  ebd <- auk_state(ebd, "CA-BC")
  expect_equal(ebd$filters$state, c("CA-BC", "CR-P", "US-TX"))
  
  # no duplication
  ebd <- auk_state(ebd, rep(state, 2))
  expect_equal(ebd$filters$state, c("CA-BC", "CR-P", "US-TX"))
  
  # overwrite
  ebd <- auk_state(ebd, "CA-BC", replace = TRUE)
  expect_equal(ebd$filters$state, "CA-BC")
  
  # raises error for bad states
  expect_error(auk_state(ebd, "US-XX"))
  expect_error(auk_state(ebd, "AA-AA"))
  expect_error(auk_state(ebd, ""))
  expect_error(auk_state(ebd, NA))
})

test_that("auk_county", {
  county <- c("CA-ON-NG", "US-NY-109")
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd() %>%
    auk_county(county)
  
  # works correctly
  expect_equal(ebd$filters$county, county)
  
  # add
  ebd <- auk_county(ebd, "US-TX-505")
  expect_equal(ebd$filters$county, c("CA-ON-NG", "US-NY-109", "US-TX-505"))
  
  # no duplication
  ebd <- auk_county(ebd, rep(county, 2))
  expect_equal(ebd$filters$county, c("CA-ON-NG", "US-NY-109", "US-TX-505"))
  
  # overwrite
  ebd <- auk_county(ebd, "US-NY-109", replace = TRUE)
  expect_equal(ebd$filters$county, "US-NY-109")
  
  # raises error for bad counties
  expect_error(auk_county(ebd, NA))
})

test_that("auk_country/state/county mutually exclusive", {
  county <- "US-NY-109"
  state <- c("CR-P", "US-TX")
  country <- c("Costa Rica", "US")
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd() %>%
    auk_state(state)
  
  expect_length(ebd$filters$country, 0)
  expect_length(ebd$filters$state, 2)
  expect_length(ebd$filters$county, 0)
  ebd <- auk_country(ebd, country)
  expect_length(ebd$filters$country, 2)
  expect_length(ebd$filters$state, 0)
  expect_length(ebd$filters$county, 0)
  ebd <- auk_county(ebd, county)
  expect_length(ebd$filters$country, 0)
  expect_length(ebd$filters$state, 0)
  expect_length(ebd$filters$county, 1)
  ebd <- auk_state(ebd, state)
  expect_length(ebd$filters$country, 0)
  expect_length(ebd$filters$state, 2)
  expect_length(ebd$filters$county, 0)
})

test_that("auk_bcr", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd() %>% 
    auk_bcr(bcr = 24)
  
  # works correctly
  expect_equal(ebd$filters$bcr, 24)
  
  # multiple bcrs
  ebd <- auk_bcr(ebd, bcr = c(24, 22))
  expect_equal(ebd$filters$bcr, c(22, 24))
  
  # raises error for bad input
  expect_error(auk_bcr(ebd, "22"))
  expect_error(auk_bcr(ebd, 2.2))
  expect_error(auk_bcr(ebd, 0))
  expect_error(auk_bcr(ebd, 100))
})

test_that("auk_bbox", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd()
  
  # works correctly
  e <- c(-125, 37, -120, 52)
  ebd <- auk_bbox(ebd, e)
  expect_equal(ebd$filters$bbox, e)
  
  # overwrite
  e <- c(0, 0, 1, 1)
  ebd <- auk_bbox(ebd, e)
  expect_equal(ebd$filters$bbox, e)
  
  # invalid lat
  expect_error(auk_bbox(ebd, c(0, -91, 1, 1)))
  expect_error(auk_bbox(ebd, c(0, -90, 1, 91)))
  expect_error(auk_bbox(ebd, c(0, 1, 1, 0)))
  expect_error(auk_bbox(ebd, c(0, 0, 1, 0)))
  # invalid lng
  expect_error(auk_bbox(ebd, c(-181, 0, 1, 1)))
  expect_error(auk_bbox(ebd, c(-180, 0, 181, 1)))
  expect_error(auk_bbox(ebd, c(1, 0, 0, 1)))
  expect_error(auk_bbox(ebd, c(0, 0, 0, 1)))
})

test_that("auk_year", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd()
  
  # character input
  y <- c(2010, 2012)
  ebd <- auk_year(ebd, y)
  expect_equivalent(ebd$filters$year, y)
  
  # invalid year format
  expect_error(auk_year(ebd, 1000))
  expect_error(auk_date(ebd, "2010"))
  expect_error(auk_date(ebd, NA))
  expect_error(auk_date(ebd, 2010.1))
})

test_that("auk_date", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd()
  
  # character input
  d <- c("2015-01-01", "2015-12-31")
  ebd <- auk_date(ebd, d)
  expect_equivalent(ebd$filters$date, d)
  expect_true(!attr(ebd$filters$date, "wildcard"))
  # date input
  ebd <- auk_date(ebd, as.Date(d))
  expect_equivalent(ebd$filters$date, d)
  
  # single day is ok
  d <- c("2015-01-01", "2015-01-01")
  ebd <- auk_date(ebd, d)
  expect_equivalent(ebd$filters$date, d)
  
  # overwrite
  d <- c("2010-01-01", "2010-12-31")
  ebd <- auk_date(ebd, d)
  expect_equivalent(ebd$filters$date, d)
  
  # invalid date format
  expect_error(auk_date(ebd, c("01-01-2015", "2015-12-31")))
  expect_error(auk_date(ebd, c("2015-00-01", "2015-12-31")))
  expect_error(auk_date(ebd, c("2015-01-32", "2015-12-31")))
  expect_error(auk_date(ebd, c("a", "b")))
  expect_error(auk_date(ebd, "2010-01-01"))
  
  # dates not sequential
  expect_error(auk_date(ebd, c("2015-12-31", "2015-01-01")))
})

test_that("auk_date wildcards", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd()
  
  d <- c("*-05-01", "*-06-30")
  ebd <- auk_date(ebd, d)
  expect_equivalent(ebd$filters$date, d)
  expect_true(!attr(ebd$filters$date, "wrap"))
  expect_true(attr(ebd$filters$date, "wildcard"))
  
  # invalid date format
  expect_error(auk_date(ebd, "*-01-01"))
  expect_error(auk_date(ebd, c("*-05-01", "2012-06-30")))
  
  # dates can wrap
  wrapped <- auk_date(ebd, c("*-12-31", "*-01-01"))
  expect_is(wrapped, "auk_ebd")
  expect_true(attr(wrapped$filters$date, "wrap"))
  expect_true(attr(wrapped$filters$date, "wildcard"))
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

test_that("auk_protocol", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd() %>% 
    auk_protocol("Stationary")
  
  # works correctly
  expect_equal(ebd$filters$protocol, "Stationary")
  
  # multiple protocols
  ebd <- auk_protocol(ebd, c("Stationary", "Traveling"))
  expect_equal(ebd$filters$protocol, c("Stationary", "Traveling"))
  
  # raises error for bad input
  expect_error(auk_protocol(ebd, "STATIONARY"))
  expect_error(auk_protocol(ebd, 2))
  expect_error(auk_protocol(ebd, ""))
  expect_error(auk_protocol(ebd, NA))
})

test_that("auk_project", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd() %>% 
    auk_project("EBIRD")
  
  # works correctly
  expect_equal(ebd$filters$project, "EBIRD")
  
  # multiple projects
  ebd <- auk_project(ebd, c("EBIRD", "EBIRD_MEX"))
  expect_equal(ebd$filters$project, c("EBIRD", "EBIRD_MEX"))
  
  # raises error for bad input
  expect_error(auk_project(ebd, "EBIRD MEX"))
  expect_error(auk_project(ebd, "ebird_mex"))
  expect_error(auk_project(ebd, 2))
  expect_error(auk_project(ebd, ""))
  expect_error(auk_project(ebd, NA))
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

test_that("auk_distance", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd()
  
  # works correctly
  d <- c(0, 10)
  ebd <- auk_distance(ebd, d)
  expect_equal(ebd$filters$distance, d)
  
  # overwrite
  d <- c(5, 10)
  ebd <- auk_distance(ebd, d)
  expect_equal(ebd$filters$distance, d)
  
  # miles conversion
  d <- c(5, 10)
  ebd_km <- auk_distance(ebd, d)
  ebd_miles <- auk_distance(ebd, 0.621371 * d, distance_units = "miles")
  expect_equal(round(ebd_km$filters$distance, 1), 
               round(ebd_miles$filters$distance, 1))
  
  # invalid distance format
  expect_error(auk_distance(ebd, c("0", "10")))
  expect_error(auk_distance(ebd, 0))
  expect_error(auk_distance(ebd, c(0, 5, 10)))
  expect_error(auk_distance(ebd, c(-10, 10)))
  
  # distances not sequential
  expect_error(auk_distance(ebd, c(10, 5)))
})

test_that("auk_complete", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd()
  
  # works correctly
  expect_equal(ebd$filters$complete, FALSE)
  ebd <- auk_complete(ebd)
  expect_equal(ebd$filters$complete, TRUE)
})

test_that("auk_breeding", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd()
  
  # works correctly
  expect_equal(ebd$filters$complete, FALSE)
  ebd <- auk_complete(ebd)
  expect_equal(ebd$filters$complete, TRUE)
})

test_that("auk_observer", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd()
  
  # works with character
  obs <- "obsr313215"
  ebd <- auk_observer(ebd, obs)
  expect_equal(ebd$filters$observer, obs)
  
  # works with integer
  obs_int <- 313215
  ebd <- auk_observer(ebd, obs_int)
  expect_equal(ebd$filters$observer, obs)
})

test_that("auk_exotic", {
  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
    auk_ebd()
  
  # works with character
  ex_code <- ""
  ebd <- auk_exotic(ebd, ex_code)
  expect_equal(ebd$filters$exotic, ex_code)
  
  # works with integer
  ex_code <- c("", "X")
  ebd <- auk_exotic(ebd, ex_code)
  expect_equal(ebd$filters$exotic, ex_code)
})