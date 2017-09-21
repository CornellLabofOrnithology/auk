
<!-- README.md is generated from README.Rmd. Please edit that file -->
auk: eBird Data Extraction and Processing with AWK
==================================================

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0) [![Travis-CI Build Status](https://img.shields.io/travis/CornellLabofOrnithology/auk/master.svg?label=Mac%20OSX%20%26%20Linux)](https://travis-ci.org/CornellLabofOrnithology/auk) [![AppVeyor Build Status](https://img.shields.io/appveyor/ci/mstrimas/auk/master.svg?label=Windows)](https://ci.appveyor.com/project/mstrimas/auk) [![Coverage Status](https://img.shields.io/codecov/c/github/CornellLabofOrnithology/auk/master.svg)](https://codecov.io/github/CornellLabofOrnithology/auk?branch=master) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/auk)](https://cran.r-project.org/package=auk) [![Downloads](http://cranlogs.r-pkg.org/badges/auk?color=brightgreen)](http://www.r-pkg.org/pkg/auk)

**This package is in development. If you encounter any bugs, please open an issue on GitHub**

Overview
--------

[eBird](http://www.ebird.org) is an online tool for recording bird observations. Since its inception, nearly 500 million records of bird sightings (i.e. combinations of location, date, time, and bird species) have been collected, making eBird one of the largest citizen science projects in history and an extremely valuable resource for bird research and conservation. The full eBird database is packaged as a text file and available for download as the [eBird Basic Dataset (EBD)](http://ebird.org/ebird/data/download). Due to the large size of this dataset, it must be filtered to a smaller subset of desired observations before reading into R. This filtering is most efficiently done using AWK, a Unix utility and programming language for processing column formatted text data. This package acts as a front end for AWK, allowing users to filter eBird data before import into R.

Installation
------------

``` r
# cran release
install.packages("auk")

# or install the development version from github
# install.packages("devtools")
devtools::install_github("CornellLabofOrnithology/auk")
```

`auk` requires the Unix utility AWK, which is available on most Linux and Mac OS X machines. Windows users will first need to install [Cygwin](https://www.cygwin.com) before using this package. Note that **Cygwin must be installed in the default location** (`C:/cygwin/bin/gawk.exe` or `C:/cygwin64/bin/gawk.exe`) in order for `auk` to work.

Vignette
--------

Full details on using `auk` to produce both presence-only and presence-absence data are outlined in the vignette, which can be accessed with `vignette("auk")`.

A note on versions
------------------

This package contains a current (as of the time of package release) version of the [bird taxonomy used by eBird](http://help.ebird.org/customer/portal/articles/1006825-the-ebird-taxonomy). This taxonomy determines the species that can be reported in eBird and therefore the species that users of `auk` can extract. eBird releases an updated taxonomy once a year, typically in August, at which time `auk` will be updated to include the current taxonomy. When using `auk`, users should be careful to ensure that the version they're using is in sync with the eBird Basic Dataset they're working with. This is most easily accomplished by always using the must recent version of `auk` and the most recent release of the dataset.

Quick start
-----------

This package uses the command-line program AWK to extract subsets of the eBird Basic Dataset for use in R. This is a multi-step process:

1.  Define a reference to the eBird data file.
2.  Define a set of spatial, temporal, or taxonomic filters. Each type of filter corresponds to a different function, e.g. `auk_species` to filter by species. At this stage the filters are only set up, no actual filtering is done until the next step.
3.  Filter the eBird data text file, producing a new text file with only the selected rows.
4.  Import this text file into R as a data frame.

Because the eBird dataset is so large, step 3 typically takes several hours to run. Here's a simple example that extract all Gray Jay records from within Canada.

``` r
library(auk)
# path to the ebird data file, here a sample included in the package
input_file <- system.file("extdata/ebd-sample.txt", package = "auk")
# output text file
output_file <- "ebd_filtered_grja.txt"
ebird_data <- input_file %>% 
  # 1. reference file
  auk_ebd() %>% 
  # 2. define filters
  auk_species(species = "Gray Jay") %>% 
  auk_country(country = "Canada") %>% 
  # 3. run filtering
  auk_filter(file = output_file) %>% 
  # 4. read text file into r data frame
  read_ebd()
```

For those not familiar with the pipe operator (`%>%`), the above code could be rewritten:

``` r
input_file <- system.file("extdata/ebd-sample.txt", package = "auk")
output_file <- "ebd_filtered_grja.txt"
ebd <- auk_ebd(input_file)
ebd_filters <- auk_species(ebd, species = "Gray Jay")
ebd_filters <- auk_country(ebd_filters, country = "Canada")
ebd_filtered <- auk_filter(ebd_filters, file = output_file)
ebd_df <- read_ebd(ebd_filtered)
```

Usage
-----

### Cleaning

Some rows in the dataset may have an incorrect number of columns, typically from problematic characters in the comments fields, and the dataset has an extra blank column at the end. The function `auk_clean()` drops these erroneous records and removes the blank column.

``` r
library(auk)
# sample data
f <- system.file("extdata/ebd-sample_messy.txt", package = "auk")
tmp <- tempfile()
# remove problem records
auk_clean(f, tmp)
#> [1] "/var/folders/mg/qh40qmqd7376xn8qxd6hm5lwjyy0h2/T//RtmpPfluJG/file79cf52261e89"
# number of lines in input
length(readLines(f))
#> [1] 101
# number of lines in output
length(readLines(tmp))
#> [1] 96
```

### Filtering

`auk` uses a [pipeline-based workflow](http://r4ds.had.co.nz/pipes.html) for defining filters, which can then be compiled into an AWK script. Users should start by defining a reference to the dataset file with `auk_ebd()`. Then any of the following filters can be applied:

-   `auk_species()`: filter by species using common or scientific names.
-   `auk_country()`: filter by country using the standard English names or [ISO 2-letter country codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2).
-   `auk_extent()`: filter by spatial extent, i.e. a range of latitudes and longitudes in decimal degrees.
-   `auk_date()`: filter to checklists from a range of dates.
-   `auk_last_edited()`: filter to checklists from a range of last edited dates, useful for extracting just new or recently edited data.
-   `auk_time()`: filter to checklists started during a range of times-of-day.
-   `auk_duration()`: filter to checklists with observation durations within a given range.
-   `auk_distance()`: filter to checklists with distances travelled within a given range.
-   `auk_complete()`: only retain checklists in which the observer has specified that they recorded all species seen or heard. It is necessary to retain only complete records for the creation of presence-absence data, because the "absence"" information is inferred by the lack of reporting of a species on checklists.

Note that all of the functions listed above only modify the `auk_ebd` object, in order to define the filters. Once the filters have been defined, the filtering is actually conducted using `auk_filter()`.

``` r
# sample data
f <- system.file("extdata/ebd-sample.txt", package = "auk")
# define an EBD reference and a set of filters
ebd <- auk_ebd(f) %>% 
  # species: common and scientific names can be mixed
  auk_species(species = c("Gray Jay", "Cyanocitta cristata")) %>%
  # country: codes and names can be mixed; case insensitive
  auk_country(country = c("US", "Canada", "mexico")) %>%
  # extent: long and lat in decimal degrees
  # formatted as `c(lng_min, lat_min, lng_max, lat_max)`
  auk_extent(extent = c(-100, 37, -80, 52)) %>%
  # date: use standard ISO date format `"YYYY-MM-DD"`
  auk_date(date = c("2012-01-01", "2012-12-31")) %>%
  # time: 24h format
  auk_time(start_time = c("06:00", "09:00")) %>%
  # duration: length in minutes of checklists
  auk_duration(duration = c(0, 60)) %>%
  # complete: all species seen or heard are recorded
  auk_complete()
ebd
#> Input 
#>   EBD: /Library/Frameworks/R.framework/Versions/3.4/Resources/library/auk/extdata/ebd-sample.txt 
#> 
#> Output 
#>   Filters not executed
#> 
#> Filters 
#>   Species: Cyanocitta cristata, Perisoreus canadensis
#>   Countries: CA, MX, US
#>   Spatial extent: Lon -100 - -80; Lat 37 - 52
#>   Date: 2012-01-01 - 2012-12-31
#>   Start time: 06:00-09:00
#>   Last edited date: all
#>   Duration: 0-60 minutes
#>   Distance travelled: all
#>   Complete checklists only: yes
```

In all cases, extensive checks are performed to ensure filters are valid. For example, species are checked against the official [eBird taxonomy](http://help.ebird.org/customer/portal/articles/1006825-the-ebird-taxonomy) and countries are checked using the [`countrycode`](https://github.com/vincentarelbundock/countrycode) package.

Each of the functions described in the *Defining filters* section only defines a filter. Once all of the required filters have been set, `auk_filter()` should be used to compile them into an AWK script and execute it to produce an output file. So, as an example of bringing all of these steps together, the following commands will extract all Gray Jay and Blue Jay records from Canada and save the results to a tab-separated text file for subsequent use:

``` r
output_file <- "ebd_filtered_blja-grja.txt"
ebd_filtered <- system.file("extdata/ebd-sample.txt", package = "auk") %>% 
  auk_ebd() %>% 
  auk_species(species = c("Gray Jay", "Cyanocitta cristata")) %>% 
  auk_country(country = "Canada") %>% 
  auk_filter(file = output_file)
```

**Filtering the full dataset typically takes at least a couple hours**, so set it running then go grab lunch!

### Reading

eBird Basic Dataset files can be read with `read_ebd()`:

``` r
system.file("extdata/ebd-sample.txt", package = "auk") %>% 
  read_ebd() %>% 
  str()
#> Classes 'tbl_df', 'tbl' and 'data.frame':    487 obs. of  47 variables:
#>  $ checklist_id              : chr  "S12813888" "S14439115" "S10152130" "S20381156" ...
#>  $ global_unique_identifier  : chr  "URN:CornellLabOfOrnithology:EBIRD:OBS179266095" "URN:CornellLabOfOrnithology:EBIRD:OBS201696412" "URN:CornellLabOfOrnithology:EBIRD:OBS144228837" "URN:CornellLabOfOrnithology:EBIRD:OBS278542844" ...
#>  $ last_edited_date          : chr  "2013-02-02 15:17:20" "2013-06-18 13:03:16" "2017-03-03 11:30:08" "2014-10-30 15:19:52" ...
#>  $ taxonomic_order           : num  18772 18772 18772 18816 18772 ...
#>  $ category                  : chr  "species" "species" "species" "species" ...
#>  $ common_name               : chr  "Green Jay" "Green Jay" "Green Jay" "Steller's Jay" ...
#>  $ scientific_name           : chr  "Cyanocorax yncas" "Cyanocorax yncas" "Cyanocorax yncas" "Cyanocitta stelleri" ...
#>  $ subspecies_common_name    : chr  NA NA NA NA ...
#>  $ subspecies_scientific_name: chr  NA NA NA NA ...
#>  $ observation_count         : chr  "X" "4" "1" "2" ...
#>  $ breeding_bird_atlas_code  : chr  NA NA NA NA ...
#>  $ age_sex                   : chr  NA NA NA NA ...
#>  $ country                   : chr  "Mexico" "Mexico" "Belize" "Mexico" ...
#>  $ country_code              : chr  "MX" "MX" "BZ" "MX" ...
#>  $ state                     : chr  "Tamaulipas" "Chiapas" "Belize" "Chiapas" ...
#>  $ state_code                : chr  "MX-TAM" "MX-CHP" "BZ-BZ" "MX-CHP" ...
#>  $ county                    : chr  NA NA NA NA ...
#>  $ county_code               : chr  NA NA NA NA ...
#>  $ iba_code                  : chr  NA "MX_169" NA "MX_200" ...
#>  $ bcr_code                  : int  36 60 NA NA 56 47 60 56 NA 60 ...
#>  $ usfws_code                : chr  NA NA NA NA ...
#>  $ atlas_block               : chr  NA NA NA NA ...
#>  $ locality                  : chr  "Mexico across river from Salineno" "MtySantuario_Punto_10" "Crooked Tree Village west" "San Antonio( Bosque mesofilo Punto 6)" ...
#>  $ locality_id               : chr  "L1914289" "L2234972" "L1444745" "L3141369" ...
#>  $ locality_type             : chr  "P" "P" "P" "P" ...
#>  $ latitude                  : num  26.5 15.7 17.8 15.1 20.9 ...
#>  $ longitude                 : num  -99.1 -92.9 -88.5 -92.1 -88.4 ...
#>  $ observation_date          : Date, format: "2010-11-12" "2012-05-06" ...
#>  $ time_observations_started : chr  "07:20:00" "10:30:00" "06:50:00" "10:30:00" ...
#>  $ observer_id               : chr  "obsr347082" "obsr313215" "obsr246930" "obsr354246" ...
#>  $ first_name                : chr  "Beth" "MONITORES COMUNITARIOS" "Lee" "CBM" ...
#>  $ last_name                 : chr  "eBirder" "eBirder" "eBirder" "eBirder" ...
#>  $ sampling_event_identifier : chr  "S12813888" "S14439115" "S10152130" "S20381156" ...
#>  $ protocol_type             : chr  "eBird - Stationary Count" "eBird - Traveling Count" "eBird - Traveling Count" "eBird - Stationary Count" ...
#>  $ project_code              : chr  "EBIRD" "EBIRD" "EBIRD" "EBIRD" ...
#>  $ duration_minutes          : int  40 10 100 10 110 55 10 60 60 10 ...
#>  $ effort_distance_km        : num  NA 0.257 1.127 NA 1.2 ...
#>  $ effort_area_ha            : num  NA NA NA NA NA ...
#>  $ number_observers          : int  20 1 2 4 2 2 1 1 4 1 ...
#>  $ all_species_reported      : logi  TRUE TRUE TRUE TRUE TRUE TRUE ...
#>  $ group_identifier          : chr  NA NA NA NA ...
#>  $ has_media                 : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
#>  $ approved                  : logi  TRUE TRUE TRUE TRUE TRUE TRUE ...
#>  $ reviewed                  : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
#>  $ reason                    : chr  NA NA NA NA ...
#>  $ trip_comments             : chr  "RGV Bird Festival Trip, viewed from the US side of the river" "Placido Morales Hdz en  Santuario, Angel Albino Corzo, 1556 msnm." "With Glenn Crawford and 3 tourists. Glenn says that the frog calls that are heard nearly everywhere in Belize d"| __truncated__ "Muestreo realizado por Antonio, Ren� y Evaristo" ...
#>  $ species_comments          : chr  NA NA NA NA ...
```

Presence-absence data
---------------------

For many applications, presence-only data are sufficient; however, for modeling and analysis, presence-absence data are required. `auk` includes functionality to produce presence-absence data from eBird checklists. For full details, consult the vignette: `vignette("auk")`.

Code of Conduct
---------------

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

Acknowledgements
----------------

This package is based on AWK scripts provided as part of the eBird Data Workshop given by Wesley Hochachka, Daniel Fink, Tom Auer, and Frank La Sorte at the 2016 NAOC on August 15, 2016.

References
----------

    eBird Basic Dataset. Version: ebd_relMay-2017. Cornell Lab of Ornithology, Ithaca, New York. May 2013.
