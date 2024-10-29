library(tidyverse)
library(stringi)
library(readxl)
library(auk)

# via api -----

# eBird taxonomy
# typically updated annually in the late summer
ebird_taxonomy <- get_ebird_taxonomy() %>%
  # ascii conversion
  mutate(common_name = stri_trans_general(common_name, "latin-ascii")) %>% 
  as.data.frame(stringsAsFactors = FALSE)

write_csv(ebird_taxonomy, "data-raw/ebird-taxonomy.csv", na = "")
usethis::use_data(ebird_taxonomy, overwrite = TRUE, compress = "xz")
filter(ebird_taxonomy, scientific_name == "Gyps rueppelli")


# via csv - including common family names -----

extract_family <- function(x) {
  str_match(x, "\\((.*)\\)")[, 2, drop = TRUE]
}
ebird_taxonomy <- paste0("https://www.birds.cornell.edu/",
                         "clementschecklist/wp-content/uploads/2024/10/",
                         "eBird_taxonomy_v2024.csv") %>% 
  read_csv() %>% 
  rename_all(tolower) %>% 
  mutate(common_name = stri_trans_general(primary_com_name, "latin-ascii"),
         family_common = extract_family(family),
         family = str_remove(family, " \\(.+\\)")) %>% 
  select(species_code, scientific_name = sci_name, common_name,
         order, family, family_common,
         category, taxon_order, report_as) %>% 
  as.data.frame(stringsAsFactors = FALSE)

# extinct species
ebird_taxonomy <- paste0("https://www.birds.cornell.edu/",
                         "clementschecklist/wp-content/uploads/2024/10/",
                         "Clements-v2024-October-2024-rev.csv") %>% 
  read_csv() %>% 
  filter(category == "species") %>% 
  transmute(scientific_name = `scientific name`,
            extinct = !is.na(extinct) & extinct == 1) %>% 
  left_join(ebird_taxonomy, ., by = "scientific_name")

write_csv(ebird_taxonomy, "data-raw/ebird-taxonomy.csv", na = "")
usethis::use_data(ebird_taxonomy, overwrite = TRUE, compress = "xz")
