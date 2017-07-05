library(tidyverse)
library(stringi)

# eBird taxonomy
# source: http://help.ebird.org/customer/en/portal/articles/1006825-the-ebird-taxonomy
# typically updated annually in the late summer
ebird_taxonomy <- read_csv("data-raw/eBird_Taxonomy_v2016.csv", 
                           na = c("NA", "")) %>%
  select(category = CATEGORY, species_code = SPECIES_CODE,
         name_common = PRIMARY_COM_NAME, name_scientific = SCI_NAME,
         order = ORDER, family = FAMILY) %>%
  # ascii conversion
  mutate(name_common = stri_trans_general(name_common, "latin-ascii")) %>%
  as.data.frame(stringsAsFactors = FALSE)

write_csv(ebird_taxonomy, "data-raw/ebird-taxonomy.csv", na = "")
devtools::use_data(ebird_taxonomy, overwrite = TRUE, compress = "xz")