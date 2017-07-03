## ---- echo = FALSE-------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  warning = FALSE, error = FALSE, message = FALSE
)
suppressPackageStartupMessages(library(auk))

## ----example-data-1, eval = FALSE----------------------------------------
#  system.file("extdata/ebd-sample.txt", package = "auk")

## ----example-data-2, eval = FALSE----------------------------------------
#  # ebd
#  system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
#  # sampling event data
#  system.file("extdata/zerofill-ex_sampling.txt", package = "auk")

## ----auk-clean, eval = FALSE---------------------------------------------
#  library(auk)
#  # sample data, with intentially introduced errors
#  f <- system.file("extdata/ebd-sample_messy.txt", package = "auk")
#  f_out <- "ebd_cleaned.txt"
#  # remove problem records
#  cleaned <- auk_clean(f, f_out = f_out)
#  # tidy up
#  unlink(f_out)

## ----auk-ebd-------------------------------------------------------------
ebd <- system.file("extdata/ebd-sample_messy.txt", package = "auk") %>% 
  auk_ebd()
ebd

## ----auk-filter----------------------------------------------------------
ebd <- ebd %>% 
  # species: common and scientific names can be mixed
  auk_species(species = c("Gray Jay", "Cyanocitta cristata")) %>%
  # country: codes and names can be mixed; case insensitive
  auk_country(country = c("US", "Canada", "mexico")) %>%
  # extent: formatted as `c(lng_min, lat_min, lng_max, lat_max)`
  auk_extent(extent = c(-100, 37, -80, 52)) %>%
  # date: use standard ISO date format `"YYYY-MM-DD"`
  auk_date(date = c("2012-01-01", "2012-12-31")) %>%
  # time: 24h format
  auk_time(time = c("06:00", "09:00")) %>%
  # duration: length in minutes of checklists
  auk_duration(duration = c(0, 60)) %>%
  # complete: all species seen or heard are recorded
  auk_complete()
ebd

## ----auk-complete, eval = FALSE------------------------------------------
#  output_file <- "ebd_filtered_blja-grja.txt"
#  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
#    auk_ebd() %>%
#    auk_species(species = c("Gray Jay", "Cyanocitta cristata")) %>%
#    auk_country(country = "Canada") %>%
#    auk_filter(file = output_file)
#  # tidy up
#  unlink(output_file)

## ----read----------------------------------------------------------------
system.file("extdata/ebd-sample.txt", package = "auk") %>% 
  read_ebd() %>% 
  str()

## ----read-tbl------------------------------------------------------------
ebd_df <- system.file("extdata/ebd-sample.txt", package = "auk") %>% 
  read_ebd(setclass = "data.frame")

## ----read-auk-ebd, eval = FALSE------------------------------------------
#  output_file <- "ebd_filtered_blja-grja.txt"
#  ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
#    auk_ebd() %>%
#    auk_species(species = c("Gray Jay", "Cyanocitta cristata")) %>%
#    auk_country(country = "Canada") %>%
#    auk_filter(file = output_file) %>%
#    read_ebd()
#  # tidy up
#  unlink(output_file)

## ----awk-script----------------------------------------------------------
awk_script <- system.file("extdata/ebd-sample.txt", package = "auk") %>% 
  auk_ebd() %>% 
  auk_species(species = c("Gray Jay", "Cyanocitta cristata")) %>% 
  auk_country(country = "Canada") %>% 
  auk_filter(awk_file = "awk-script.txt", execute = FALSE)
# read back in and prepare for printing
awk_file <- readLines(awk_script)
awk_file[!grepl("^[[:space:]]*$", awk_file)] %>% 
  paste0(collapse = "\n") %>% 
  cat()
# tidy up
unlink(awk_script)

## ----auk-unique----------------------------------------------------------
# read in an ebd file and don't automatically remove duplicates
ebd <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
  read_ebd(unique = FALSE)
# remove duplicates
ebd_unique <- auk_unique(ebd)
# compare number of rows
nrow(ebd)
nrow(ebd_unique)

## ----ebd-zf--------------------------------------------------------------
# to produce zero-filled data, provide an EBD and sampling event data file
f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
f_smp <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
filters <- auk_ebd(f_ebd, file_sampling = f_smp) %>% 
  auk_species("Collared Kingfisher") %>% 
  auk_time(c("06:00", "10:00")) %>% 
  auk_complete()
filters

## ----zf-filter-fake, echo = TRUE-----------------------------------------
# needed to allow building vignette on machines without awk
ebd_filtered <- filters
ebd_filtered$output <- "ebd-filtered.txt"
ebd_filtered$output_sampling <- "sampling-filtered.txt"

## ----zf-filter, eval = -1------------------------------------------------
ebd_filtered <- auk_filter(filters, 
                           file = "ebd-filtered.txt",
                           file_sampling = "sampling-filtered.txt")
ebd_filtered

## ----auk-zf-fake, echo = FALSE-------------------------------------------
# needed to allow building vignette on machines without awk
fake_ebd <- read_ebd(f_ebd)
fake_smp <- read_sampling(f_smp)
# filter in R to fake AWK call
fake_ebd <- subset(
  fake_ebd, 
  all_species_reported & 
    scientific_name %in% ebd_filtered$filters$species & 
    time_observations_started >= ebd_filtered$filters$time[1] & 
    time_observations_started <= ebd_filtered$filters$time[2])
fake_smp <- subset(
  fake_smp, 
  all_species_reported & 
    time_observations_started >= ebd_filtered$filters$time[1] & 
    time_observations_started <= ebd_filtered$filters$time[2])
ebd_zf <- auk_zerofill(fake_ebd, fake_smp)

## ----auk-zf, eval = -1---------------------------------------------------
ebd_zf <- auk_zerofill(ebd_filtered)
ebd_zf

## ----zf-components-------------------------------------------------------
head(ebd_zf$observations)
str(ebd_zf$sampling_events)

## ----zf-collapse, eval = -1----------------------------------------------
ebd_zf_df <- auk_zerofill(ebd_filtered, collapse = TRUE)
ebd_zf_df <- collapse_zerofill(ebd_zf)
class(ebd_zf_df)
names(ebd_zf_df)

