library(tidyverse)
library(stringi)

# eBird taxonomy
# source: http://help.ebird.org/customer/en/portal/articles/1006825-the-ebird-taxonomy
# typically updated annually in the late summer
ebird_taxonomy <- read_csv("data-raw/eBird_Taxonomy_v2016.csv", 
                           na = c("NA", "")) %>%
  set_names(tolower(names(.))) %>% 
  select(taxon_order, category, species_code,
         common_name = primary_com_name, scientific_name = sci_name,
         order, family, report_as) %>%
  # ascii conversion
  mutate(common_name = stri_trans_general(common_name, "latin-ascii")) %>% 
  as.data.frame(stringsAsFactors = FALSE)

write_csv(ebird_taxonomy, "data-raw/ebird-taxonomy.csv", na = "")
devtools::use_data(ebird_taxonomy, overwrite = TRUE, compress = "xz")