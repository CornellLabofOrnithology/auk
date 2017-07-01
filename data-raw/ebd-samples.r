library(auk)
library(tidyverse)

ebird_dir <- "~/data/ebird/ebd_relFeb-2017/"
# ebd
f_orig <- file.path(ebird_dir, "ebd_relFeb-2017.txt")
f_clean <- file.path(ebird_dir, "ebd_relFeb-2017_clean.txt")
f_subset <- file.path(ebird_dir, "ebd_relFeb-2017_subset.txt")
f_sg <- file.path(ebird_dir, "ebd_relFeb-2017_SG.txt")
# sampling
s_orig <- file.path(ebird_dir, "ebd_sampling_relFeb-2017.txt")
s_clean <- file.path(ebird_dir, "ebd_sampling_relFeb-2017_clean.txt")
s_subset <- file.path(ebird_dir, "ebd_sampling_relFeb-2017_subset.txt")
s_sg <- file.path(ebird_dir, "ebd_sampling_relFeb-2017_SG.txt")

# clean
auk_clean(f_orig, f_clean, overwrite = TRUE)
auk_clean(s_orig, s_clean, overwrite = TRUE)

# filter
filters <- auk_ebd(f_clean, s_clean) %>%
  auk_species(species = c("Gray Jay", "Blue Jay", "Steller's Jay", "Green Jay")) %>%
  auk_country(country = c("US", "Canada", "Mexico", "Belize", "Guatemala", "Honduras", "Panama", "Costa Rica", "El Salvador")) %>%
  auk_date(date = c("2010-01-01", "2012-12-31")) %>%
  auk_time(time = c("06:00", "12:00")) %>%
  auk_duration(duration = c(0, 120))
filter_time <- system.time({
  auk_filter(filters, file = f_subset, file_sampling = s_subset, overwrite = TRUE)
})

x <- read_tsv(f_subset, quote = "", col_types = cols(.default = col_character()))
x$`LAST NAME` <- "eBirder"
# sample to 500 records, make sure to get some from central america
y1 <- sample_n(x %>% filter(!`COUNTRY CODE` %in% c("CA", "US")), 100)
y2 <- sample_n(x %>% filter(`COUNTRY CODE` %in% c("CA", "US")), 400)
y <- bind_rows(y1, y2)
write_tsv(y, "inst/extdata/ebd-sample.txt", na = "")
# prepare a smaller sample of messy data
y <- mutate(y, x1 = "")
y <- sample_n(y, 100)
write_tsv(y, "inst/extdata/ebd-sample_messy.txt", na = "")

# filter for zero-fill example
filters <- auk_ebd(f_clean, s_clean) %>%
  auk_species(species = c("Collared Kingfisher", "White-throated Kingfisher", "Blue-eared Kingfisher")) %>%
  auk_country(country = "Singapore") %>%
  auk_date(date = c("2012-01-01", "2012-12-31"))
filter_time <- system.time({
  auk_filter(filters, file = f_sg, file_sampling = s_sg, overwrite = TRUE)
})

# export
x_ebd <- read_tsv(f_sg, quote = "", col_types = cols(.default = col_character()))
x_ebd$`LAST NAME` <- "eBirder"
write_tsv(x_ebd, "inst/extdata/zerofill-ex_ebd.txt", na = "")
x_samp <- read_tsv(s_sg, quote = "", col_types = cols(.default = col_character()))
x_samp$`LAST NAME` <- "eBirder"
write_tsv(x_samp, "inst/extdata/zerofill-ex_sampling.txt", na = "")

# manual editing after script is run
# 1. Remove all " characters from all four files
# 2. Manually edited the messy file to introduce errors, especially tabs in comment fields
# 3. Remove x1 from the end of the header row in the messy file.
