library(auk)
library(tidyverse)

ebird_dir <- "~/data/ebird/ebd_relFeb-2018/"
# ebd
f <- file.path(ebird_dir, "ebd_relFeb-2018.txt")
f_subset <- file.path(ebird_dir, "ebd_relFeb-2018_subset.txt")
f_sg <- file.path(ebird_dir, "ebd_relFeb-2018_SG.txt")
f_ru <- file.path(ebird_dir, "ebd_relFeb-2018_rollup.txt")
# sampling
s <- file.path(ebird_dir, "ebd_sampling_relFeb-2018.txt")
s_subset <- file.path(ebird_dir, "ebd_sampling_relFeb-2018_subset.txt")
s_sg <- file.path(ebird_dir, "ebd_sampling_relFeb-2018_SG.txt")

# filter
filters <- auk_ebd(f) %>%
  auk_species(species = c("Gray Jay", "Blue Jay", "Steller's Jay", "Green Jay")) %>%
  auk_country(country = c("US", "Canada", "Mexico", "Belize", "Guatemala", "Honduras", "Panama", "Costa Rica", "El Salvador")) %>%
  auk_date(date = c("2010-01-01", "2012-12-31")) %>%
  auk_time(start_time = c("06:00", "12:00")) %>%
  auk_duration(duration = c(0, 120))
filter_time <- system.time({
  auk_filter(filters, file = f_subset, overwrite = TRUE)
})

x <- read_tsv(f_subset, quote = "", col_types = cols(.default = col_character())) %>% 
  mutate(`LAST NAME` = "eBirder") %>% 
  select(-X49)
# evenly sample species
set.seed(1)
n_min <- min(table(x$`SCIENTIFIC NAME`))
x <- x %>% 
  group_by(`SCIENTIFIC NAME`) %>% 
  sample_n(n_min) %>% 
  ungroup()
# sample to 500 records, make sure to get some from central america
y1 <- sample_n(x %>% filter(!`COUNTRY CODE` %in% c("CA", "US")), 100)
y2 <- sample_n(x %>% filter(`COUNTRY CODE` %in% c("CA", "US")), 400)
y <- bind_rows(y1, y2)
write_tsv(y %>% select(-X49), "inst/extdata/ebd-sample.txt", na = "")
# prepare a smaller sample of messy data
names(y)[length(y)] <- ""
y <- sample_n(y, 100)
write_tsv(y, "inst/extdata/ebd-sample_messy.txt", na = "")

# filter for zero-fill example
filters <- auk_ebd(f, s) %>%
  auk_species(species = c("Collared Kingfisher", "White-throated Kingfisher", "Blue-eared Kingfisher")) %>%
  auk_country(country = "Singapore") %>%
  auk_date(date = c("2012-01-01", "2012-12-31"))
filter_time <- system.time({
  auk_filter(filters, file = f_sg, file_sampling = s_sg, overwrite = TRUE)
})

# export
x_ebd <- read_tsv(f_sg, quote = "", col_types = cols(.default = col_character())) %>% 
  mutate(`LAST NAME` = "eBirder") %>% 
  select(-X49)
write_tsv(x_ebd, "inst/extdata/zerofill-ex_ebd.txt", na = "")
x_samp <- read_tsv(s_sg, quote = "", col_types = cols(.default = col_character())) %>% 
  mutate(`LAST NAME` = "eBirder") %>% 
  select(-X33)
write_tsv(x_samp, "inst/extdata/zerofill-ex_sampling.txt", na = "")

# rollup
paste("head -1", f, ">", f_ru) %>% 
  system()
paste("tail -1000000", f, ">>", f_ru) %>% 
  system()
x_ebd <- read_tsv(f_ru, quote = "", col_types = cols(.default = col_character())) %>% 
  mutate(`LAST NAME` = "eBirder") %>% 
  select(-X49)
# yellow-rumped
set.seed(1)
ru_ex <- filter(x_ebd, `SAMPLING EVENT IDENTIFIER` == "S41507433", 
             `COMMON NAME` == "Yellow-rumped Warbler")
ru_ex <- x_ebd %>% 
  filter(CATEGORY %in% c("spuh", "slash", "hybrid", "domestic", "form", "intergrade")) %>% 
  group_by(CATEGORY) %>% 
  sample_n(3) %>% 
  ungroup() %>% 
  rbind(ru_ex)
write_tsv(ru_ex, "inst/extdata/ebd-rollup-ex.txt", na = "")

# manual editing after script is run
# 1. Remove all " characters from all four files
# 2. Manually edited the messy file to introduce errors, especially tabs in comment fields
# 3. Remove x1 from the end of the header row in the messy file.
