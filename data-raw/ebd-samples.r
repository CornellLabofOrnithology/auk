library(auk)
library(fs)
library(glue)
library(stringi)
library(tidyverse)

ebird_dir <- "~/data/ebird/auk/"

# US observations ----

obs_sampled <- NULL
for (species in c("gryjay", "grnjay", "blujay")) {
  tf <- tempfile()
  # further filtering
  filtered <- glue("ebd_{species}_201001_201212_relSep-2023.txt") %>% 
    path(ebird_dir, .) %>% 
    auk_ebd() %>% 
    auk_country(country = c("US", "Canada", "Mexico", "Belize", 
                            "Guatemala", "Honduras", "Panama", 
                            "Costa Rica", "El Salvador")) %>%
    auk_date(date = c("2010-01-01", "2012-12-31")) %>%
    auk_time(start_time = c("06:00", "12:00")) %>%
    auk_duration(duration = c(0, 120)) %>% 
    auk_filter(tf)
  
  # import
  obs <- read_tsv(tf, quote = "", col_types = cols(.default = "c")) %>% 
    select(-`...50`)
  
  # sample 500 observations
  set.seed(1)
  # sample to 500 records, make sure to get some from central america
  if (species == "grnjay") {
    s1 <- obs %>% 
      filter(!`COUNTRY CODE` %in% c("CA", "US")) %>% 
      slice_sample(n = 100)
    s2 <- obs %>% 
      filter(`COUNTRY CODE` %in% c("CA", "US")) %>% 
      slice_sample(n = 100)
    sampled <- bind_rows(s1, s2)
  } else {
    sampled <- slice_sample(obs, n = 100)
  }
  obs_sampled <- bind_rows(obs_sampled, sampled)
  unlink(tf)
}
# save as package data
f <- "inst/extdata/ebd-sample.txt"
write_tsv(obs_sampled, f, na = "")

# remove any non-ascii characters
readLines(f) %>% 
  stri_trans_general("latin-ascii") %>% 
  iconv("latin1", "ASCII", sub="") %>% 
  str_replace_all("\"", "") %>% 
  writeLines(f)
stopifnot(length(tools::showNonASCII(readLines(f))) == 0)
stopifnot(all(read_ebd(f)$scientific_name %in% ebird_taxonomy$scientific_name))


# singapore zero-fill ----

# filter to focal species
f_ebd_in <- path(ebird_dir, 
                 "ebd_SG_201201_201212_smp_relSep-2023",
                 "ebd_SG_201201_201212_smp_relSep-2023.txt")
f_sed_in <- path(ebird_dir, 
                 "ebd_SG_201201_201212_smp_relSep-2023",
                 "ebd_SG_201201_201212_smp_relSep-2023_sampling.txt")
f_ebd_out <- "inst/extdata/zerofill-ex_ebd.txt"
f_sed_out <- "inst/extdata/zerofill-ex_sampling.txt"
filtered <- auk_ebd(f_ebd_in, f_sed_in) %>% 
  auk_species(species = c("Collared Kingfisher", "White-throated Kingfisher", 
                          "Blue-eared Kingfisher")) %>%
  auk_country(country = "Singapore") %>%
  auk_date(date = c("2012-01-01", "2012-07-30")) %>% 
  auk_complete() %>% 
  auk_filter(file = f_ebd_out, file_sampling = f_sed_out, overwrite = TRUE)

# remove any non-ascii characters
readLines(f_ebd_out) %>% 
  stri_trans_general("latin-ascii") %>% 
  iconv("latin1", "ASCII", sub="") %>% 
  str_replace_all("\"", "") %>% 
  writeLines(f_ebd_out)
stopifnot(length(tools::showNonASCII(readLines(f_ebd_out))) == 0)
stopifnot(all(read_ebd(f_ebd_out)$scientific_name %in% ebird_taxonomy$scientific_name))
readLines(f_sed_out) %>% 
  stri_trans_general("latin-ascii") %>% 
  iconv("latin1", "ASCII", sub="") %>% 
  str_replace_all("\"", "") %>% 
  writeLines(f_sed_out)
stopifnot(length(tools::showNonASCII(readLines(f_sed_out))) == 0)


# colorado rollup ----

ebd <- path(ebird_dir,
            "ebd_US-CO_201801_201812_relSep-2023",
            "ebd_US-CO_201801_201812_relSep-2023.txt") %>% 
  read_tsv(quote = "", col_types = cols(.default = "c")) %>% 
  select(-...50)
# checklist with all three yrwa types
ru_ex <- ebd %>% 
  filter(`SAMPLING EVENT IDENTIFIER` == "S129851825",
         `COMMON NAME` == "Yellow-rumped Warbler")
set.seed(1)
ru_ex <- ebd %>% 
  filter(CATEGORY %in% c("spuh", "slash", "hybrid", "domestic", "form", 
                         "intergrade")) %>% 
  group_by(CATEGORY) %>% 
  slice_sample(n = 3) %>% 
  ungroup() %>% 
  bind_rows(ru_ex) %>% 
  mutate(`GROUP IDENTIFIER` = "")
f <- "inst/extdata/ebd-rollup-ex.txt"
write_tsv(ru_ex, f, na = "")
# remove any non-ascii characters
readLines(f) %>% 
  stri_trans_general("latin-ascii") %>% 
  iconv("latin1", "ASCII", sub="") %>% 
  str_replace_all("\"", "") %>% 
  writeLines(f)
stopifnot(length(tools::showNonASCII(readLines(f))) == 0)
stopifnot(all(read_ebd(f)$scientific_name %in% ebird_taxonomy$scientific_name))
