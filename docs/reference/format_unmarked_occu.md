# Format EBD data for occupancy modeling with `unmarked`

Prepare a data frame of species observations for ingestion into the
package `unmarked` for hierarchical modeling of abundance and
occurrence. The function
[`unmarked::formatWide()`](https://ecoverseR.github.io/unmarked/reference/formatWideLong.html)
takes a data frame and converts it to one of several `unmarked` objects,
which can then be used for modeling. This function converts data from a
format in which each row is an observation (e.g. as in the eBird Basic
Dataset) to the esoteric format required by
[`unmarked::formatWide()`](https://ecoverseR.github.io/unmarked/reference/formatWideLong.html)
in which each row is a site.

## Usage

``` r
format_unmarked_occu(
  x,
  site_id = "site",
  response = "species_observed",
  site_covs,
  obs_covs
)
```

## Arguments

- x:

  `data.frame`; observation data, e.g. from the eBird Basic Dataset
  (EBD), for **a single species**, that has been filtered to those with
  repeat visits by
  [`filter_repeat_visits()`](https://cornelllabofornithology.github.io/auk/reference/filter_repeat_visits.md).

- site_id:

  character; a unique idenitifer for each "site", typically identifying
  observations from a unique location by the same observer within a
  period of temporal closure. Data output from
  [`filter_repeat_visits()`](https://cornelllabofornithology.github.io/auk/reference/filter_repeat_visits.md)
  will have a `.site_id` variable that meets these requirements.

- response:

  character; the variable that will act as the response in modeling
  efforts, typically a binary variable indicating presence or absence or
  a count of individuals seen.

- site_covs:

  character; the variables that will act as site-level covariates, i.e.
  covariates that vary at the site level, for example,
  latitude/longitude or habitat predictors. If this parameter is
  missing, it will be assumed that any variable that is not an
  observation-level covariate (`obs_covs`) or the `site_id`, is a
  site-level covariate.

- obs_covs:

  character; the variables that will act as observation-level
  covariates, i.e. covariates that vary within sites, at the level of
  observations, for example, time or length of observation.

## Value

A data frame that can be processed by
[`unmarked::formatWide()`](https://ecoverseR.github.io/unmarked/reference/formatWideLong.html).
Each row will correspond to a unqiue site and, assuming there are a
maximum of `N` observations per site, columns will be as follows:

1.  The unique site identifier, named "site".

2.  `N` response columns, one for each observation, named "y.1", ...,
    "y.N".

3.  Columns for each of the site-level covariates.

4.  Groups of `N` columns of observation-level covariates, one column
    per covariate per observation, names "covariate_name.1", ...,
    "covariate_name.N".

## Details

Hierarchical modeling requires repeat observations at each "site" to
estimate detectability. A "site" is typically defined as a geographic
location visited by the same observer within a period of temporal
closure. To define these sites and filter out observations that do not
correspond to repeat visits, users should use
[`filter_repeat_visits()`](https://cornelllabofornithology.github.io/auk/reference/filter_repeat_visits.md),
then pass the output to this function.

`format_unmarked_occu()` is designed to prepare data to be converted
into an `unmarkedFrameOccu` object for occupancy modeling with
[`unmarked::occu()`](https://ecoverseR.github.io/unmarked/reference/occu.html);
however, it can also be used to prepare data for conversion to an
`unmarkedFramePCount` object for abundance modeling with
[`unmarked::pcount()`](https://ecoverseR.github.io/unmarked/reference/pcount.html).

## See also

Other modeling:
[`filter_repeat_visits()`](https://cornelllabofornithology.github.io/auk/reference/filter_repeat_visits.md)

## Examples

``` r
# read and zero-fill the ebd data
f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
# data must be for a single species
ebd_zf <- auk_zerofill(x = f_ebd, sampling_events = f_smpl,
                       species = "Collared Kingfisher",
                       collapse = TRUE)
occ <- filter_repeat_visits(ebd_zf, n_days = 30)
# format for unmarked
# typically one would join in habitat covariates prior to this step
occ_wide <- format_unmarked_occu(occ,
                                 response = "species_observed",
                                 site_covs = c("latitude", "longitude"),
                                 obs_covs = c("effort_distance_km", 
                                              "duration_minutes"))
# create an unmarked object
if (requireNamespace("unmarked", quietly = TRUE)) {
  occ_um <- unmarked::formatWide(occ_wide, type = "unmarkedFrameOccu")
  unmarked::summary(occ_um)
}
#> unmarkedFrame Object
#> 
#> 70 sites
#> Maximum number of observations per site: 10 
#> Mean number of observations per site: 3.7 
#> Sites with at least one detection: 40 
#> 
#> Tabulation of y observations:
#> FALSE  TRUE  <NA> 
#>   173    86   441 
#> 
#> Site-level covariates:
#>     latitude       longitude    
#>  Min.   :1.206   Min.   :103.7  
#>  1st Qu.:1.307   1st Qu.:103.7  
#>  Median :1.337   Median :103.8  
#>  Mean   :1.335   Mean   :103.8  
#>  3rd Qu.:1.354   3rd Qu.:103.9  
#>  Max.   :1.446   Max.   :104.0  
#> 
#> Observation-level covariates:
#>  effort_distance_km duration_minutes
#>  Min.   : 0.100     Min.   :  1.00  
#>  1st Qu.: 0.200     1st Qu.: 15.00  
#>  Median : 1.000     Median : 30.00  
#>  Mean   : 1.391     Mean   : 64.59  
#>  3rd Qu.: 2.000     3rd Qu.: 80.00  
#>  Max.   :10.000     Max.   :480.00  
#>  NA's   :617        NA's   :617     

# this function can also be used for abundance modeling
abd <- ebd_zf |> 
  # convert count to integer, drop records with no count
  dplyr::mutate(observation_count = as.integer(observation_count)) |> 
  dplyr::filter(!is.na(observation_count)) |> 
  # filter to repeated visits
  filter_repeat_visits(n_days = 30)
#> Warning: There was 1 warning in `dplyr::mutate()`.
#> ℹ In argument: `observation_count = as.integer(observation_count)`.
#> Caused by warning:
#> ! NAs introduced by coercion
# prepare for conversion to unmarkedFramePCount object
abd_wide <- format_unmarked_occu(abd,
                                 response = "observation_count",
                                 site_covs = c("latitude", "longitude"),
                                 obs_covs = c("effort_distance_km", 
                                              "duration_minutes"))
# create an unmarked object
if (requireNamespace("unmarked", quietly = TRUE)) {
  abd_um <- unmarked::formatWide(abd_wide, type = "unmarkedFrameOccu")
  unmarked::summary(abd_um)
}
#> unmarkedFrame Object
#> 
#> 69 sites
#> Maximum number of observations per site: 10 
#> Mean number of observations per site: 3.72 
#> Sites with at least one detection: 38 
#> 
#> Tabulation of y observations:
#>    0    1    2    3    4    5    6    7    9   10 <NA> 
#>  179   37   18    6    5    6    2    1    1    2  433 
#> 
#> Site-level covariates:
#>     latitude       longitude    
#>  Min.   :1.206   Min.   :103.7  
#>  1st Qu.:1.305   1st Qu.:103.7  
#>  Median :1.337   Median :103.8  
#>  Mean   :1.334   Mean   :103.8  
#>  3rd Qu.:1.354   3rd Qu.:103.9  
#>  Max.   :1.446   Max.   :104.0  
#> 
#> Observation-level covariates:
#>  effort_distance_km duration_minutes
#>  Min.   : 0.100     Min.   :  1.00  
#>  1st Qu.: 0.200     1st Qu.: 15.00  
#>  Median : 1.000     Median : 30.00  
#>  Mean   : 1.403     Mean   : 63.54  
#>  3rd Qu.: 2.000     3rd Qu.: 75.00  
#>  Max.   :10.000     Max.   :480.00  
#>  NA's   :605        NA's   :605     
```
