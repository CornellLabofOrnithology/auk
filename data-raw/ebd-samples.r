library(auk)
library(tidyverse)
library(stringi)
library(stringr)

ebird_dir <- "~/data/ebird/ebd_relFeb-2018/"
# ebd
f_in <- file.path(ebird_dir, "ebd_relFeb-2018.txt")
f_subset <- file.path(ebird_dir, "ebd_relFeb-2018_subset.txt")
f_sg <- file.path(ebird_dir, "ebd_relFeb-2018_SG.txt")
f_ru <- file.path(ebird_dir, "ebd_relFeb-2018_rollup.txt")
# sampling
s_in <- file.path(ebird_dir, "ebd_sampling_relFeb-2018.txt")
s_subset <- file.path(ebird_dir, "ebd_sampling_relFeb-2018_subset.txt")
s_sg <- file.path(ebird_dir, "ebd_sampling_relFeb-2018_SG.txt")

# filter
filters <- auk_ebd(f_in) %>%
  auk_species(species = c("Gray Jay", "Blue Jay", "Steller's Jay", "Green Jay")) %>%
  auk_country(country = c("US", "Canada", "Mexico", "Belize", "Guatemala", "Honduras", "Panama", "Costa Rica", "El Salvador")) %>%
  auk_date(date = c("2010-01-01", "2012-12-31")) %>%
  auk_time(start_time = c("06:00", "12:00")) %>%
  auk_duration(duration = c(0, 120))
if (!file.exists(f_subset)) {
  auk_filter(filters, file = f_subset, overwrite = TRUE)
}

x <- read_tsv(f_subset, quote = "", 
              col_types = cols(.default = col_character())) %>% 
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
y <- bind_rows(y1, y2) %>% 
  # fill with fake names for privacy
  mutate(`FIRST NAME` = stri_trans_general(`FIRST NAME`, "latin-ascii"),
         `LAST NAME` = "eBirder")
f <- "inst/extdata/ebd-sample.txt"
write_tsv(y, f, na = "")
# remove any non-ascii characters
readLines(f) %>% 
  stri_trans_general("latin-ascii") %>% 
  iconv("latin1", "ASCII", sub="") %>% 
  str_replace_all("'|\"", "") %>% 
  writeLines(f)
stopifnot(length(tools::showNonASCII(readLines(f))) == 0)
stopifnot(all(read_ebd(f)$scientific_name %in% ebird_taxonomy$scientific_name))
# prepare a smaller sample of messy data
y <- read_tsv(f, quote = "", 
              col_types = cols(.default = col_character()))
y$empty_col <- NA_character_
names(y)[length(y)] <- ""
y <- sample_n(y, 50)
f <- "inst/extdata/ebd-sample_messy.txt"
write_tsv(y, f, na = "")
readLines(f) %>% 
  str_replace_all("'|\"", "") %>% 
  writeLines(f)
stopifnot(length(tools::showNonASCII(readLines(f))) == 0)
stopifnot(all(read_ebd(f)$scientific_name %in% ebird_taxonomy$scientific_name))

# filter for zero-fill example
filters <- auk_ebd(f_in, s_in) %>%
  auk_species(species = c("Collared Kingfisher", "White-throated Kingfisher", "Blue-eared Kingfisher")) %>%
  auk_country(country = "Singapore") %>%
  auk_date(date = c("2012-01-01", "2012-12-31"))
if (!file.exists(f_sg)) {
  auk_filter(filters, file = f_sg, file_sampling = s_sg, overwrite = TRUE)
}

# export
# observations
x_ebd <- read_tsv(f_sg, quote = "", 
                  col_types = cols(.default = col_character())) %>% 
  select(-X49) %>% 
  mutate(`FIRST NAME` = stri_trans_general(`FIRST NAME`, "latin-ascii"),
         `LAST NAME` = "eBirder")
f <- "inst/extdata/zerofill-ex_ebd.txt"
write_tsv(x_ebd, f, na = "")
# remove any non-ascii characters
readLines(f) %>% 
  stri_trans_general("latin-ascii") %>% 
  iconv("latin1", "ASCII", sub="") %>% 
  str_replace_all("'|\"", "") %>% 
  writeLines(f)
stopifnot(length(tools::showNonASCII(readLines(f))) == 0)
stopifnot(all(read_ebd(f)$scientific_name %in% ebird_taxonomy$scientific_name))
# checklists
x_samp <- read_tsv(s_sg, quote = "", col_types = cols(.default = col_character())) %>% 
  select(-X33) %>% 
  mutate(`FIRST NAME` = stri_trans_general(`FIRST NAME`, "latin-ascii"),
         `LAST NAME` = "eBirder")
f <- "inst/extdata/zerofill-ex_sampling.txt"
write_tsv(x_samp, f, na = "")
# remove any non-ascii characters
readLines(f) %>% 
  stri_trans_general("latin-ascii") %>% 
  iconv("latin1", "ASCII", sub="") %>% 
  str_replace_all("'|\"", "") %>% 
  writeLines(f)
stopifnot(length(tools::showNonASCII(readLines(f))) == 0)

# rollup
if (!file.exists(f_ru)) {
  paste("head -1", f_in, ">", f_ru) %>% 
    system()
  paste("tail -1000000", f_in, ">>", f_ru) %>% 
    system()
}
x_ebd <- read_tsv(f_ru, quote = "", col_types = cols(.default = col_character())) %>% 
  select(-X49) %>% 
  mutate(`FIRST NAME` = stri_trans_general(`FIRST NAME`, "latin-ascii"),
         `LAST NAME` = "eBirder")
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
f <- "inst/extdata/ebd-rollup-ex.txt"
write_tsv(ru_ex, f, na = "")
# remove any non-ascii characters
readLines(f) %>% 
  stri_trans_general("latin-ascii") %>% 
  iconv("latin1", "ASCII", sub="") %>% 
  str_replace_all("'|\"", "") %>% 
  writeLines(f)
stopifnot(length(tools::showNonASCII(readLines(f))) == 0)
stopifnot(all(read_ebd(f)$scientific_name %in% ebird_taxonomy$scientific_name))

# after script: edit the messy file to introduce errors, especially tabs in comment fields
f <- "inst/extdata/ebd-sample_messy.txt"
stopifnot(length(tools::showNonASCII(readLines(f))) == 0)
stopifnot(all(read_ebd(f, reader = "base")$scientific_name %in% ebird_taxonomy$scientific_name))
