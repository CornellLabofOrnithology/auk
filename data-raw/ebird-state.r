library(tidyverse)
library(stringi)
library(stringr)
library(countrycode)
library(janitor)
dir <- "/Users/mes335/data/ebird/ebd_relFeb-2018/"
  
# run in terminal
# cd /Users/mes335/data/ebird/ebd_relFeb-2018/
# awk -F $'\t' 'BEGIN{OFS = "\t"}{print $2,$3,$4,$5}' ebd_sampling_relFeb-2018_clean.txt > ebd_sampling_country-state.txt
# head -1 ebd_sampling_country-state.txt > ebird_country-state.txt
# tail -n +2 ebd_sampling_country-state.txt | sort -u  >> ebird_country-state.txt

ebird_states <- file.path(dir, "ebird_country-state.txt") |> 
  read_tsv() |> 
  clean_names() |> 
  filter(!str_detect(state_code, "-$")) |> 
  mutate(country = stri_enc_toascii(country),
         state = stri_enc_toascii(state))
usethis::use_data(ebird_states, overwrite = TRUE, compress = "xz")
