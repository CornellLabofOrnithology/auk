## ---- echo = FALSE-------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  warning = FALSE, error = FALSE, message = FALSE
)
suppressPackageStartupMessages(library(auk))
suppressPackageStartupMessages(library(dplyr))

## ----quickstart, eval = FALSE--------------------------------------------
#  library(auk)
#  library(dplyr)
#  # path to the ebird data file, here a sample included in the package
#  input_file <- system.file("extdata/ebd-sample.txt", package = "auk")
#  # output text file
#  output_file <- "ebd_filtered_grja.txt"
#  ebird_data <- input_file %>%
#    # 1. reference file
#    auk_ebd() %>%
#    # 2. define filters
#    auk_species(species = "Gray Jay") %>%
#    auk_country(country = "Canada") %>%
#    # 3. run filtering
#    auk_filter(file = output_file) %>%
#    # 4. read text file into r data frame
#    read_ebd()

## ----quickstart-nopipes, eval = FALSE------------------------------------
#  input_file <- system.file("extdata/ebd-sample.txt", package = "auk")
#  output_file <- "ebd_filtered_grja.txt"
#  ebd <- auk_ebd(input_file)
#  ebd_filters <- auk_species(ebd, species = "Gray Jay")
#  ebd_filters <- auk_country(ebd_filters, country = "Canada")
#  ebd_filtered <- auk_filter(ebd_filters, file = output_file)
#  ebd_df <- read_ebd(ebd_filtered)

## ----example-data-1, eval = FALSE----------------------------------------
#  library(auk)
#  library(dplyr)
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

## ----auk-ebd-------------------------------------------------------------
ebd <- system.file("extdata/ebd-sample_messy.txt", package = "auk") %>% 
  auk_ebd()
ebd

## ----auk-filter----------------------------------------------------------
ebd_filters <- ebd %>% 
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
ebd_filters

## ----auk-complete, eval = FALSE------------------------------------------
#  output_file <- "ebd_filtered_blja-grja.txt"
#  ebd_jays <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
#    auk_ebd() %>%
#    auk_species(species = c("Gray Jay", "Cyanocitta cristata")) %>%
#    auk_country(country = "Canada") %>%
#    auk_filter(file = output_file)

## ----read----------------------------------------------------------------
system.file("extdata/ebd-sample.txt", package = "auk") %>% 
  read_ebd() %>% 
  glimpse()

## ----read-auk-ebd, eval = FALSE------------------------------------------
#  output_file <- "ebd_filtered_blja-grja.txt"
#  ebd_df <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
#    auk_ebd() %>%
#    auk_species(species = c("Gray Jay", "Cyanocitta cristata")) %>%
#    auk_country(country = "Canada") %>%
#    auk_filter(file = output_file) %>%
#    read_ebd()

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

## ----auk-unique----------------------------------------------------------
# read in an ebd file and don't automatically remove duplicates
ebd_dupes <- system.file("extdata/ebd-sample.txt", package = "auk") %>%
  read_ebd(unique = FALSE)
# remove duplicates
ebd_unique <- auk_unique(ebd_dupes)
# compare number of rows
nrow(ebd_dupes)
nrow(ebd_unique)

## ----auk-rollup----------------------------------------------------------
ebd_noru <- system.file("extdata/ebd-rollup-ex.txt", package = "auk") %>%
  read_ebd(rollup = FALSE)
# note the presence of forms for american robin and bewick's wren
ebd_noru %>% 
  filter(checklist_id == "S7980609") %>% 
  select(id = checklist_id, category, 
         species = common_name, subspecies = subspecies_common_name)
# taxonomic rollup
ebd_noru %>% 
  auk_rollup() %>% 
  filter(checklist_id == "S7980609") %>% 
  select(id = checklist_id, category,
         species = common_name, subspecies = subspecies_common_name)

## ----ebd-zf--------------------------------------------------------------
# to produce zero-filled data, provide an EBD and sampling event data file
f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
f_smp <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
filters <- auk_ebd(f_ebd, file_sampling = f_smp) %>% 
  auk_species("Collared Kingfisher") %>% 
  auk_time(c("06:00", "10:00")) %>% 
  auk_complete()
filters

## ----zf-filter-fake, echo = FALSE----------------------------------------
# needed to allow building vignette on machines without awk
ebd_sed_filtered <- filters
ebd_sed_filtered$output <- "ebd-filtered.txt"
ebd_sed_filtered$output_sampling <- "sampling-filtered.txt"

## ----zf-filter, eval = -1------------------------------------------------
ebd_sed_filtered <- auk_filter(filters, 
                               file = "ebd-filtered.txt",
                               file_sampling = "sampling-filtered.txt")
ebd_sed_filtered

## ----auk-zf-fake, echo = FALSE-------------------------------------------
# needed to allow building vignette on machines without awk
fake_ebd <- read_ebd(f_ebd)
fake_smp <- read_sampling(f_smp)
# filter in R to fake AWK call
fake_ebd <- subset(
  fake_ebd, 
  all_species_reported & 
    scientific_name %in% ebd_sed_filtered$filters$species & 
    time_observations_started >= ebd_sed_filtered$filters$time[1] & 
    time_observations_started <= ebd_sed_filtered$filters$time[2])
fake_smp <- subset(
  fake_smp, 
  all_species_reported & 
    time_observations_started >= ebd_sed_filtered$filters$time[1] & 
    time_observations_started <= ebd_sed_filtered$filters$time[2])
ebd_zf <- auk_zerofill(fake_ebd, fake_smp)

## ----auk-zf, eval = -1---------------------------------------------------
ebd_zf <- auk_zerofill(ebd_sed_filtered)
ebd_zf

## ----zf-components-------------------------------------------------------
head(ebd_zf$observations)
glimpse(ebd_zf$sampling_events)

## ----zf-collapse, eval = -1----------------------------------------------
ebd_zf_df <- auk_zerofill(ebd_filtered, collapse = TRUE)
ebd_zf_df <- collapse_zerofill(ebd_zf)
class(ebd_zf_df)
ebd_zf_df

