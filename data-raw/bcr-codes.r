library(tidyverse)
library(janitor)

bcr_codes <- read_tsv("data-raw/BCRCodes.txt") |> 
  clean_names() |> 
  mutate(bcr_name = str_replace_all(bcr_name, "_", " ") |> 
           str_to_title())
usethis::use_data(bcr_codes, overwrite = TRUE, compress = "xz")
