context("sampling event filter definition")

test_that("auk_country", {
  country <- c("CA", "United States", "mexico")
  sed <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") %>%
    auk_sampling() %>%
    auk_country(country)
  
  # works correctly
  expect_equal(sed$filters$country, c("CA", "MX", "US"))
  
  # add
  sed <- auk_country(sed, "Belize")
  expect_equal(sed$filters$country, c("BZ", "CA", "MX", "US"))
  
  # no duplication
  sed <- auk_country(sed, rep(country, 2), replace = TRUE)
  expect_equal(sed$filters$country, c("CA", "MX", "US"))
  
  # overwrite
  sed <- auk_country(sed, "Belize", replace = TRUE)
  expect_equal(sed$filters$country, "BZ")
  
  # just code
  sed <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") %>%
    auk_sampling() %>%
    auk_country("CA")
  expect_equal(sed$filters$country, "CA")
  # just name
  sed <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") %>%
    auk_sampling()%>%
    auk_country("Canada")
  expect_equal(sed$filters$country, "CA")
  
  # raises error for bad countries
  expect_error(auk_country(sed, "Atlantis"))
  expect_error(auk_country(sed, "AA"))
  expect_error(auk_country(sed, ""))
  expect_error(auk_country(sed, NA))
})

test_that("auk_state", {
  state <- c("CR-P", "US-TX")
  sed <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") %>%
    auk_sampling() %>%
    auk_state(state)
  
  # works correctly
  expect_equal(sed$filters$state, state)
  
  # add
  sed <- auk_state(sed, "CA-BC")
  expect_equal(sed$filters$state, c("CA-BC", "CR-P", "US-TX"))
  
  # no duplication
  sed <- auk_state(sed, rep(state, 2))
  expect_equal(sed$filters$state, c("CA-BC", "CR-P", "US-TX"))
  
  # overwrite
  sed <- auk_state(sed, "CA-BC", replace = TRUE)
  expect_equal(sed$filters$state, "CA-BC")
  
  # raises error for bad states
  expect_error(auk_state(sed, "US-XX"))
  expect_error(auk_state(sed, "AA-AA"))
  expect_error(auk_state(sed, ""))
  expect_error(auk_state(sed, NA))
})

test_that("auk_county", {
  county <- c("CA-ON-NG", "US-NY-109")
  sed <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") %>%
    auk_sampling() %>%
    auk_county(county)
  
  # works correctly
  expect_equal(sed$filters$county, county)
  
  # add
  sed <- auk_county(sed, "US-TX-505")
  expect_equal(sed$filters$county, c("CA-ON-NG", "US-NY-109", "US-TX-505"))
  
  # no duplication
  sed <- auk_county(sed, rep(county, 2))
  expect_equal(sed$filters$county, c("CA-ON-NG", "US-NY-109", "US-TX-505"))
  
  # overwrite
  sed <- auk_county(sed, "US-NY-109", replace = TRUE)
  expect_equal(sed$filters$county, "US-NY-109")
  
  # raises error for bad counties
  expect_error(auk_county(sed, NA))
})

test_that("auk_bbox", {
  sed <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") %>%
    auk_sampling()
  
  # works correctly
  e <- c(-125, 37, -120, 52)
  sed <- auk_bbox(sed, e)
  expect_equal(sed$filters$bbox, e)
  
  # overwrite
  e <- c(0, 0, 1, 1)
  sed <- auk_bbox(sed, e)
  expect_equal(sed$filters$bbox, e)
  
  # invalid lat
  expect_error(auk_bbox(sed, c(0, -91, 1, 1)))
  expect_error(auk_bbox(sed, c(0, -90, 1, 91)))
  expect_error(auk_bbox(sed, c(0, 1, 1, 0)))
  expect_error(auk_bbox(sed, c(0, 0, 1, 0)))
  # invalid lng
  expect_error(auk_bbox(sed, c(-181, 0, 1, 1)))
  expect_error(auk_bbox(sed, c(-180, 0, 181, 1)))
  expect_error(auk_bbox(sed, c(1, 0, 0, 1)))
  expect_error(auk_bbox(sed, c(0, 0, 0, 1)))
})

test_that("auk_year", {
  sed <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") %>%
    auk_sampling()
  
  # character input
  y <- c(2010, 2012)
  sed <- auk_year(sed, y)
  expect_equivalent(sed$filters$year, y)
  
  # invalid year format
  expect_error(auk_year(sed, 1000))
  expect_error(auk_date(sed, "2010"))
  expect_error(auk_date(sed, NA))
  expect_error(auk_date(sed, 2010.1))
})

test_that("auk_date", {
  sed <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") %>%
    auk_sampling()
  
  # character input
  d <- c("2015-01-01", "2015-12-31")
  sed <- auk_date(sed, d)
  expect_equivalent(sed$filters$date, d)
  expect_true(!attr(sed$filters$date, "wildcard"))
  # date input
  sed <- auk_date(sed, as.Date(d))
  expect_equivalent(sed$filters$date, d)
  
  # single day is ok
  d <- c("2015-01-01", "2015-01-01")
  sed <- auk_date(sed, d)
  expect_equivalent(sed$filters$date, d)
  
  # overwrite
  d <- c("2010-01-01", "2010-12-31")
  sed <- auk_date(sed, d)
  expect_equivalent(sed$filters$date, d)
  
  # invalid date format
  expect_error(auk_date(sed, c("01-01-2015", "2015-12-31")))
  expect_error(auk_date(sed, c("2015-00-01", "2015-12-31")))
  expect_error(auk_date(sed, c("2015-01-32", "2015-12-31")))
  expect_error(auk_date(sed, c("a", "b")))
  expect_error(auk_date(sed, "2010-01-01"))
  
  # dates not sequential
  expect_error(auk_date(sed, c("2015-12-31", "2015-01-01")))
  
})

test_that("auk_last_edited", {
  sed <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") %>%
    auk_sampling()
  
  # character input
  d <- c("2015-01-01", "2015-12-31")
  sed <- auk_last_edited(sed, d)
  expect_equal(sed$filters$last_edited, d)
  # date input
  sed <- auk_last_edited(sed, as.Date(d))
  expect_equal(sed$filters$last_edited, d)
  
  # single day is ok
  d <- c("2015-01-01", "2015-01-01")
  sed <- auk_last_edited(sed, d)
  expect_equal(sed$filters$last_edited, d)
  
  # overwrite
  d <- c("2010-01-01", "2010-12-31")
  sed <- auk_last_edited(sed, d)
  expect_equal(sed$filters$last_edited, d)
  
  # invalid date format
  expect_error(auk_last_edited(sed, c("01-01-2015", "2015-12-31")))
  expect_error(auk_last_edited(sed, c("2015-00-01", "2015-12-31")))
  expect_error(auk_last_edited(sed, c("2015-01-32", "2015-12-31")))
  expect_error(auk_last_edited(sed, c("a", "b")))
  expect_error(auk_last_edited(sed, "2010-01-01"))
  expect_error(auk_last_edited(sed, "2015-01-01"))
  expect_error(auk_last_edited(sed, c("2015-01-01", "2015-02-01",
                                      "2015-03-01")))
  
  # dates not sequential
  expect_error(auk_last_edited(sed, c("2015-12-31", "2015-01-01")))
  
})

test_that("auk_protocol", {
  sed <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") %>%
    auk_sampling() %>% 
    auk_protocol("Stationary")
  
  # works correctly
  expect_equal(sed$filters$protocol, "Stationary")
  
  # multiple protocols
  sed <- auk_protocol(sed, c("Stationary", "Traveling"))
  expect_equal(sed$filters$protocol, c("Stationary", "Traveling"))
  
  # raises error for bad input
  expect_error(auk_protocol(sed, "STATIONARY"))
  expect_error(auk_protocol(sed, 2))
  expect_error(auk_protocol(sed, ""))
  expect_error(auk_protocol(sed, NA))
})

test_that("auk_project", {
  sed <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") %>%
    auk_sampling() %>% 
    auk_project("EBIRD")
  
  # works correctly
  expect_equal(sed$filters$project, "EBIRD")
  
  # multiple projects
  sed <- auk_project(sed, c("EBIRD", "EBIRD_MEX"))
  expect_equal(sed$filters$project, c("EBIRD", "EBIRD_MEX"))
})

test_that("auk_time", {
  sed <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") %>%
    auk_sampling()
  
  # works correctly
  t <- c("06:00", "08:00")
  sed <- auk_time(sed, t)
  expect_equal(sed$filters$time, t)
  
  # overwrite
  t <- c("10:00", "12:00")
  sed <- auk_time(sed, t)
  expect_equal(sed$filters$time, t)
  
  # invalid time format
  expect_error(auk_time(sed, c("10:00AM", "12:00")))
  expect_error(auk_time(sed, c("23:00", "25:00")))
  expect_error(auk_time(sed, c("07:00", "08:61")))
  expect_error(auk_time(sed, c("07.00", "08.00")))
  expect_error(auk_time(sed, "07:00"))
  expect_error(auk_time(sed, c("07:00", "08:00", "09:00")))
  expect_error(auk_time(sed, c("a", "b")))
  
  # times not sequential
  expect_error(auk_time(sed, c("08:00", "07:00")))
})

test_that("auk_duration", {
  sed <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") %>%
    auk_sampling()
  
  # works correctly
  d <- c(0, 60)
  sed <- auk_duration(sed, d)
  expect_equal(sed$filters$duration, d)
  
  # overwrite
  d <- c(60, 120)
  sed <- auk_duration(sed, d)
  expect_equal(sed$filters$duration, d)
  
  # invalid duration format
  expect_error(auk_duration(sed, c("0", "60")))
  expect_error(auk_duration(sed, 0))
  expect_error(auk_duration(sed, c(0, 60, 120)))
  expect_error(auk_duration(sed, c(-10, 10)))
  
  # durations not sequential
  expect_error(auk_duration(sed, c(60, 30)))
})

test_that("auk_distance", {
  sed <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") %>%
    auk_sampling()
  
  # works correctly
  d <- c(0, 10)
  sed <- auk_distance(sed, d)
  expect_equal(sed$filters$distance, d)
  
  # overwrite
  d <- c(5, 10)
  sed <- auk_distance(sed, d)
  expect_equal(sed$filters$distance, d)
  
  # miles conversion
  d <- c(5, 10)
  sed_km <- auk_distance(sed, d)
  sed_miles <- auk_distance(sed, 0.621371 * d, distance_units = "miles")
  expect_equal(round(sed_km$filters$distance, 1), 
               round(sed_miles$filters$distance, 1))
  
  # invalid distance format
  expect_error(auk_distance(sed, c("0", "10")))
  expect_error(auk_distance(sed, 0))
  expect_error(auk_distance(sed, c(0, 5, 10)))
  expect_error(auk_distance(sed, c(-10, 10)))
  
  # distances not sequential
  expect_error(auk_distance(sed, c(10, 5)))
})

test_that("auk_complete", {
  sed <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk") %>%
    auk_sampling()
  
  # works correctly
  expect_equal(sed$filters$complete, FALSE)
  sed <- auk_complete(sed)
  expect_equal(sed$filters$complete, TRUE)
})
