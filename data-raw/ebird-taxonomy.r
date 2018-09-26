library(tidyverse)
library(stringi)
library(readxl)
library(auk)

# eBird taxonomy
# typically updated annually in the late summer
ebird_taxonomy <- get_ebird_taxonomy() %>%
  # ascii conversion
  mutate(common_name = stri_trans_general(common_name, "latin-ascii")) %>% 
  as.data.frame(stringsAsFactors = FALSE)

write_csv(ebird_taxonomy, "data-raw/ebird-taxonomy.csv", na = "")
usethis::use_data(ebird_taxonomy, overwrite = TRUE, compress = "xz")

filter(ebird_taxonomy, scientific_name == "Gyps rueppelli")
