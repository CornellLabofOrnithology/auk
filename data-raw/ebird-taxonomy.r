library(tidyverse)
library(stringi)
library(readxl)
library(auk)

extract_family <- function(x) {
  str_match(x, "\\((.*)\\)")[, 2, drop = TRUE]
}
ebird_taxonomy <- paste0("https://www.birds.cornell.edu/",
                         "clementschecklist/wp-content/uploads/2025/10/",
                         "eBird_taxonomy_v2025.csv") |> 
  read_csv() |> 
  rename_all(tolower) |> 
  mutate(common_name = stri_trans_general(primary_com_name, "latin-ascii"),
         family_common = extract_family(family),
         family = str_remove(family, " \\(.+\\)"),
         # bug in the csv duplicating "avibase-"
         taxon_concept_id = str_replace(taxon_concept_id,
                                        "avibase-avibase-",
                                        "avibase-")) |> 
  select(species_code, taxon_concept_id,
         scientific_name = sci_name, common_name,
         order, family, family_common,
         category, taxonomic_order = taxon_order, report_as) |> 
  as.data.frame(stringsAsFactors = FALSE)

# extinct species
extinction <- paste0("https://www.birds.cornell.edu/",
                     "clementschecklist/wp-content/uploads/2025/10/",
                     "Clements_v2025-October-2025.csv") |> 
  read_csv() |> 
  filter(category == "species") |> 
  mutate(taxon_concept_id = `taxon concept ID`,
         extinct = !is.na(extinct) & extinct == 1,
         .keep = "none")
ebird_taxonomy <- left_join(ebird_taxonomy, extinction, by = "taxon_concept_id")

write_csv(ebird_taxonomy, "data-raw/ebird-taxonomy.csv", na = "")
usethis::use_data(ebird_taxonomy, overwrite = TRUE, compress = "xz")
