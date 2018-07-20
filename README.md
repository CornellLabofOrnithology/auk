<!-- README.md is generated from README.Rmd. Please edit that file -->
auk: eBird Data in R <img src="hex-logo/auk.svg" align="right" width=140/>
==========================================================================

[![License: GPL
v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)
[![Travis-CI Build
Status](https://img.shields.io/travis/CornellLabofOrnithology/auk/master.svg?label=Mac%20OSX%20%26%20Linux)](https://travis-ci.org/CornellLabofOrnithology/auk)
[![AppVeyor Build
Status](https://img.shields.io/appveyor/ci/mstrimas/auk/master.svg?label=Windows)](https://ci.appveyor.com/project/mstrimas/auk)
[![Coverage
Status](https://img.shields.io/codecov/c/github/CornellLabofOrnithology/auk/master.svg)](https://codecov.io/github/CornellLabofOrnithology/auk?branch=master)
<br/>
[![rOpenSci](https://badges.ropensci.org/136_status.svg)](https://github.com/ropensci/onboarding/issues/136)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/auk)](https://cran.r-project.org/package=auk)
[![Downloads](http://cranlogs.r-pkg.org/badges/grand-total/auk?color=brightgreen)](http://www.r-pkg.org/pkg/auk)

Overview
--------

[eBird](http://www.ebird.org) is an online tool for recording bird
observations. Since its inception, nearly 500 million records of bird
sightings (i.e. combinations of location, date, time, and bird species)
have been collected, making eBird one of the largest citizen science
projects in history and an extremely valuable resource for bird research
and conservation. The full eBird database is packaged as a text file and
available for download as the [eBird Basic Dataset
(EBD)](http://ebird.org/ebird/data/download). Due to the large size of
this dataset, it must be filtered to a smaller subset of desired
observations before reading into R. This filtering is most efficiently
done using AWK, a Unix utility and programming language for processing
column formatted text data. This package acts as a front end for AWK,
allowing users to filter eBird data before import into R.

Installation
------------

    # cran release
    install.packages("auk")

    # or install the development version from github
    # install.packages("devtools")
    devtools::install_github("CornellLabofOrnithology/auk")

`auk` requires the Unix utility AWK, which is available on most Linux
and Mac OS X machines. Windows users will first need to install
[Cygwin](https://www.cygwin.com) before using this package. Note that
**Cygwin must be installed in the default location**
(`C:/cygwin/bin/gawk.exe` or `C:/cygwin64/bin/gawk.exe`) in order for
`auk` to work.

Vignette
--------

Full details on using `auk` to produce both presence-only and
presence-absence data are outlined in the vignette, which can be
accessed with `vignette("auk")`.

`auk` vs. `rebird`
------------------

Those interested in eBird data may also want to consider
[`rebird`](https://github.com/ropensci/rebird), an R package that
provides an interface to the [eBird
APIs](https://confluence.cornell.edu/display/CLOISAPI/eBirdAPIs). The
functions in `rebird` are mostly limited to accessing recent
(i.e. within the last 30 days) observations, although `ebirdfreq()` does
provide historical frequency of observation data. In contrast, `auk`
gives access to the full set of ~ 500 million eBird observations. For
most ecological applications, users will require `auk`; however, for
some use cases, e.g. building tools for birders, `rebird` provides a
quick and easy way to access data.

A note on versions
------------------

This package contains a current (as of the time of package release)
version of the [bird taxonomy used by
eBird](http://help.ebird.org/customer/portal/articles/1006825-the-ebird-taxonomy).
This taxonomy determines the species that can be reported in eBird and
therefore the species that users of `auk` can extract. eBird releases an
updated taxonomy once a year, typically in August, at which time `auk`
will be updated to include the current taxonomy. When using `auk`, users
should be careful to ensure that the version they’re using is in sync
with the eBird Basic Dataset they’re working with. This is most easily
accomplished by always using the must recent version of `auk` and the
most recent release of the dataset.

Quick start
-----------

This package uses the command-line program AWK to extract subsets of the
eBird Basic Dataset for use in R. This is a multi-step process:

1.  Define a reference to the eBird data file.
2.  Define a set of spatial, temporal, or taxonomic filters. Each type
    of filter corresponds to a different function, e.g. `auk_species` to
    filter by species. At this stage the filters are only set up, no
    actual filtering is done until the next step.
3.  Filter the eBird data text file, producing a new text file with only
    the selected rows.
4.  Import this text file into R as a data frame.

Because the eBird dataset is so large, step 3 typically takes several
hours to run. Here’s a simple example that extract all Gray Jay records
from within Canada.

    library(auk)
    # path to the ebird data file, here a sample included in the package
    # get the path to the example data included in the package
    # in practice, provide path to ebd, e.g. f_in <- "data/ebd_relFeb-2018.txt
    f_in <- system.file("extdata/ebd-sample.txt", package = "auk")
    # output text file
    f_out <- "ebd_filtered_grja.txt"
    ebird_data <- f_in %>% 
      # 1. reference file
      auk_ebd() %>% 
      # 2. define filters
      auk_species(species = "Gray Jay") %>% 
      auk_country(country = "Canada") %>% 
      # 3. run filtering
      auk_filter(file = f_out) %>% 
      # 4. read text file into r data frame
      read_ebd()

For those not familiar with the pipe operator (`%>%`), the above code
could be rewritten:

    f_in <- system.file("extdata/ebd-sample.txt", package = "auk")
    f_out <- "ebd_filtered_grja.txt"
    ebd <- auk_ebd(f_in)
    ebd_filters <- auk_species(ebd, species = "Gray Jay")
    ebd_filters <- auk_country(ebd_filters, country = "Canada")
    ebd_filtered <- auk_filter(ebd_filters, file = f_out)
    ebd_df <- read_ebd(ebd_filtered)

Usage
-----

### Cleaning

Some rows in the dataset may have an incorrect number of columns,
typically from problematic characters in the comments fields, and the
dataset has an extra blank column at the end. The function `auk_clean()`
drops these erroneous records and removes the blank column.

    library(auk)
    # get the path to the example data included in the package
    # in practice, provide path to ebd, e.g. f <- "data/ebd_relFeb-2018.txt
    f <- system.file("extdata/ebd-sample_messy.txt", package = "auk")
    # output to a temp file for example -->
    # in practice, provide path to output file -->
    # e.g. f_out <- "output/ebd_clean.txt" -->
    f_out <- tempfile()
    # remove problem records
    auk_clean(f, f_out)
    #> [1] "/var/folders/mg/qh40qmqd7376xn8qxd6hm5lwjyy0h2/T//RtmpXCx685/filebc7d56482509"
    # number of lines in input
    length(readLines(f))
    #> [1] 51
    # number of lines in output
    length(readLines(f_out))
    #> [1] 46

### Filtering

`auk` uses a [pipeline-based workflow](http://r4ds.had.co.nz/pipes.html)
for defining filters, which can then be compiled into an AWK script.
Users should start by defining a reference to the dataset file with
`auk_ebd()`. Then any of the following filters can be applied:

-   `auk_species()`: filter by species using common or scientific names.
-   `auk_country()`: filter by country using the standard English names
    or [ISO 2-letter country
    codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2).
-   `auk_state()`: filter by state using the eBird state codes, see
    `?ebird_states`.
-   `auk_extent()`: filter by spatial extent, i.e. a range of latitudes
    and longitudes in decimal degrees.
-   `auk_date()`: filter to checklists from a range of dates. To extract
    observations from a range of dates, regardless of year, use the
    wildcard “`*`” in place of the year, e.g.
    `date = c("*-05-01", "*-06-30")` for observations from May and June
    of any year.
-   `auk_last_edited()`: filter to checklists from a range of last
    edited dates, useful for extracting just new or recently edited
    data.
-   `auk_protocol()`: filter to checklists that following a specific
    search protocol, either stationary, traveling, or casual.
-   `auk_project()`: filter to checklists collected as part of a
    specific project (e.g. a breeding bird survey).
-   `auk_time()`: filter to checklists started during a range of
    times-of-day.
-   `auk_duration()`: filter to checklists with observation durations
    within a given range.
-   `auk_distance()`: filter to checklists with distances travelled
    within a given range.
-   `auk_breeding()`: only retain observations that have an associate
    breeding bird atlas code.
-   `auk_complete()`: only retain checklists in which the observer has
    specified that they recorded all species seen or heard. It is
    necessary to retain only complete records for the creation of
    presence-absence data, because the “absence”" information is
    inferred by the lack of reporting of a species on checklists.

Note that all of the functions listed above only modify the `auk_ebd`
object, in order to define the filters. Once the filters have been
defined, the filtering is actually conducted using `auk_filter()`.

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
    #>   EBD: /Users/mes335/projects/auk/inst/extdata/ebd-sample.txt 
    #> 
    #> Output 
    #>   Filters not executed
    #> 
    #> Filters 
    #>   Species: Cyanocitta cristata, Perisoreus canadensis
    #>   Countries: CA, MX, US
    #>   States: all
    #>   Spatial extent: Lon -100 - -80; Lat 37 - 52
    #>   Date: 2012-01-01 - 2012-12-31
    #>   Start time: 06:00-09:00
    #>   Last edited date: all
    #>   Protocol: all
    #>   Project code: all
    #>   Duration: 0-60 minutes
    #>   Distance travelled: all
    #>   Records with breeding codes only: no
    #>   Complete checklists only: yes

In all cases, extensive checks are performed to ensure filters are
valid. For example, species are checked against the official [eBird
taxonomy](http://help.ebird.org/customer/portal/articles/1006825-the-ebird-taxonomy)
and countries are checked using the
[`countrycode`](https://github.com/vincentarelbundock/countrycode)
package.

Each of the functions described in the *Defining filters* section only
defines a filter. Once all of the required filters have been set,
`auk_filter()` should be used to compile them into an AWK script and
execute it to produce an output file. So, as an example of bringing all
of these steps together, the following commands will extract all Gray
Jay and Blue Jay records from Canada and save the results to a
tab-separated text file for subsequent use:

    output_file <- "ebd_filtered_blja-grja.txt"
    ebd_filtered <- system.file("extdata/ebd-sample.txt", package = "auk") %>% 
      auk_ebd() %>% 
      auk_species(species = c("Gray Jay", "Cyanocitta cristata")) %>% 
      auk_country(country = "Canada") %>% 
      auk_filter(file = output_file)

**Filtering the full dataset typically takes at least a couple hours**,
so set it running then go grab lunch!

### Reading

eBird Basic Dataset files can be read with `read_ebd()`:

    system.file("extdata/ebd-sample.txt", package = "auk") %>% 
      read_ebd() %>% 
      str()
    #> Classes 'tbl_df', 'tbl' and 'data.frame':    495 obs. of  45 variables:
    #>  $ checklist_id                : chr  "S38863093" "S9652135" "S11454809" "S6280429" ...
    #>  $ global_unique_identifier    : chr  "URN:CornellLabOfOrnithology:EBIRD:OBS528315017" "URN:CornellLabOfOrnithology:EBIRD:OBS136971897" "URN:CornellLabOfOrnithology:EBIRD:OBS162106422" "URN:CornellLabOfOrnithology:EBIRD:OBS89861233" ...
    #>  $ last_edited_date            : chr  "2017-08-28 01:20:48" "2016-08-15 17:44:23" "2016-06-10 10:33:36" "2010-04-16 13:44:34" ...
    #>  $ taxonomic_order             : num  18772 18772 18772 18772 18772 ...
    #>  $ category                    : chr  "species" "species" "species" "species" ...
    #>  $ common_name                 : chr  "Green Jay" "Green Jay" "Green Jay" "Green Jay" ...
    #>  $ scientific_name             : chr  "Cyanocorax yncas" "Cyanocorax yncas" "Cyanocorax yncas" "Cyanocorax yncas" ...
    #>  $ observation_count           : chr  "4" "4" "1" "4" ...
    #>  $ breeding_bird_atlas_code    : chr  NA NA NA NA ...
    #>  $ breeding_bird_atlas_category: chr  NA NA NA NA ...
    #>  $ age_sex                     : chr  NA NA NA NA ...
    #>  $ country                     : chr  "Mexico" "Mexico" "Honduras" "Mexico" ...
    #>  $ country_code                : chr  "MX" "MX" "HN" "MX" ...
    #>  $ state                       : chr  "Chiapas" "Yucatan" "Santa Barbara" "Tamaulipas" ...
    #>  $ state_code                  : chr  "MX-CHP" "MX-YUC" "HN-SB" "MX-TAM" ...
    #>  $ county                      : chr  NA NA NA NA ...
    #>  $ county_code                 : chr  NA NA NA NA ...
    #>  $ iba_code                    : chr  "MX_169" "MX_183" NA "MX_85" ...
    #>  $ bcr_code                    : int  61 55 NA 48 NA 60 60 60 60 60 ...
    #>  $ usfws_code                  : chr  NA NA NA NA ...
    #>  $ atlas_block                 : chr  NA NA NA NA ...
    #>  $ locality                    : chr  "07_020_Monterrey_SD_trad_P02" "Reserva de la Biosfera Ria Celestun (Yucatan)" "Dry scrub and coffee finca above Azacualpa 600 masl" "Camino de Gomez Farias a San Jose" ...
    #>  $ locality_id                 : chr  "L6220973" "L221497" "L1670276" "L876486" ...
    #>  $ locality_type               : chr  "P" "H" "P" "P" ...
    #>  $ latitude                    : num  15.4 21 15.4 23.1 17 ...
    #>  $ longitude                   : num  -92.5 -90.3 -88.5 -99.2 -88.9 ...
    #>  $ observation_date            : Date, format: "2011-12-16" "2012-01-18" ...
    #>  $ time_observations_started   : chr  "06:30:00" "10:00:00" "11:41:00" "11:00:00" ...
    #>  $ observer_id                 : chr  "obsr313215" "obsr202655" "obsr247263" "obsr162003" ...
    #>  $ sampling_event_identifier   : chr  "S38863093" "S9652135" "S11454809" "S6280429" ...
    #>  $ protocol_type               : chr  "Stationary" "Traveling" "Stationary" "Traveling" ...
    #>  $ protocol_code               : chr  "P21" "P22" "P21" "P22" ...
    #>  $ project_code                : chr  "EBIRD" "EBIRD" "EBIRD" "EBIRD" ...
    #>  $ duration_minutes            : int  10 90 28 120 90 10 10 10 10 10 ...
    #>  $ effort_distance_km          : num  NA 6.437 NA 17 0.483 ...
    #>  $ effort_area_ha              : num  NA NA NA NA NA NA NA NA NA NA ...
    #>  $ number_observers            : int  1 9 2 NA 10 1 1 1 1 1 ...
    #>  $ all_species_reported        : logi  TRUE TRUE TRUE TRUE TRUE TRUE ...
    #>  $ group_identifier            : chr  NA NA NA NA ...
    #>  $ has_media                   : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
    #>  $ approved                    : logi  TRUE TRUE TRUE TRUE TRUE TRUE ...
    #>  $ reviewed                    : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
    #>  $ reason                      : chr  NA NA NA NA ...
    #>  $ trip_comments               : chr  "Plcido Martn Morales Hernndez" NA "O Komar with Mayron Mejia (and Paul House and Iliam Rivera). We were on a hillside north of the town of Azacual"| __truncated__ NA ...
    #>  $ species_comments            : chr  NA NA NA NA ...
    #>  - attr(*, "rollup")= logi TRUE

Presence-absence data
---------------------

For many applications, presence-only data are sufficient; however, for
modeling and analysis, presence-absence data are required. `auk`
includes functionality to produce presence-absence data from eBird
checklists. For full details, consult the vignette: `vignette("auk")`.

Code of Conduct
---------------

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.

Acknowledgements
----------------

This package is based on AWK scripts provided as part of the eBird Data
Workshop given by Wesley Hochachka, Daniel Fink, Tom Auer, and Frank La
Sorte at the 2016 NAOC on August 15, 2016.

`auk` benefited significantly from the [rOpenSci](https://ropensci.org/)
review process, including helpful suggestions from [Auriel
Fournier](https://github.com/aurielfournier) and [Edmund
Hart](https://github.com/emhart).

References
----------

    eBird Basic Dataset. Version: ebd_relFeb-2018. Cornell Lab of Ornithology, Ithaca, New York. May 2013.

[![](http://www.ropensci.org/public_images/github_footer.png)](http://ropensci.org)
