library(tidyverse)
library(stringi)
library(readxl)
library(auk)

extract_family <- function(x) {
  str_match(x, "\\((.*)\\)")[, 2, drop = TRUE]
}

# ebird clements taxonomy
tax_url <- paste0(
  "https://www.birds.cornell.edu/clementschecklist/wp-content/uploads/",
  "2026/11/eBird_Taxonomy_v2026-october-2026.csv"
)
message("Download CSV and copy to data-raw/ directory:\n", tax_url)
ebird_taxonomy <- read_csv("data-raw/eBird_Taxonomy_v2026-october-2026.csv") |>

  rename_all(tolower) |>
  mutate(
    common_name = stri_trans_general(primary_com_name, "latin-ascii"),
    family_common = extract_family(family),
    family = str_remove(family, " \\(.+\\)"),
    extinct = (extinct == 1),
    report_as_filled = report_as
  ) |>
  select(
    species_code,
    taxon_concept_id = bio_concept_code,
    scientific_name = sci_name,
    common_name = primary_com_name,
    family,
    family_common,
    order = order1,
    category,
    taxonomic_order = taxon_order,
    report_as = sparse_report_as,
    report_as_filled,
    extinct
  ) |>
  as.data.frame(stringsAsFactors = FALSE)

write_csv(ebird_taxonomy, "data-raw/ebird-taxonomy.csv", na = "")
usethis::use_data(ebird_taxonomy, overwrite = TRUE, compress = "xz")
