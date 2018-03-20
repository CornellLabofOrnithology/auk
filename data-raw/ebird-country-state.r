library(tidyverse)
library(countrycode)
library(janitor)
dir <- "/Users/mes335/data/ebird/ebd_relFeb-2018/"
  
# run in terminal
# cd /Users/mes335/data/ebird/ebd_relFeb-2018/
# awk -F $'\t' 'BEGIN{OFS = "\t"}{print $2,$3,$4,$5}' ebd_sampling_relFeb-2018_clean.txt > ebd_sampling_country-state.txt
# head -1 ebd_sampling_country-state.txt > ebird_country-state.txt
# tail -n +2 ebd_sampling_country-state.txt | sort -u  >> ebird_country-state.txt

ebird_country_state <- file.path(dir, "ebird_country-state.txt") %>% 
  read_tsv() %>% 
  clean_names()

ebird_country_state %>% 
  distinct(country, country_code) %>% 
  mutate(cc_code = countrycode(country, "country.name", "iso2c")) %>% 
  filter(cc_code != country_code | is.na(cc_code)) %>% 
  mutate(country = tolower(country)) %>% 
  select(country, country_code) %>% 
  deframe() %>% 
  dput()
  View()

  
setNames(c("AC", "CP", "CS", "XX", "XK", "FM"), 
         c("ashmore and cartier islands", "clipperton island", 
           "coral sea islands", "high seas", "kosovo", "micronesia"))
