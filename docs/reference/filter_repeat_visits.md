# Filter observations to repeat visits for hierarchical modeling

Hierarchical modeling of abundance and occurrence requires repeat visits
to sites to estimate detectability. These visits should be all be within
a period of closure, i.e. when the population can be assumed to be
closed. eBird data, and many other data sources, do not explicitly
follow this protocol; however, subsets of the data can be extracted to
produce data suitable for hierarchical modeling. This function extracts
a subset of observation data that have a desired number of repeat visits
within a period of closure.

## Usage

``` r
filter_repeat_visits(
  x,
  min_obs = 2L,
  max_obs = 10L,
  annual_closure = TRUE,
  n_days = NULL,
  date_var = "observation_date",
  site_vars = c("locality_id", "observer_id"),
  ll_digits = 6L
)
```

## Arguments

- x:

  `data.frame`; observation data, e.g. data from the eBird Basic Dataset
  (EBD) zero-filled with
  [`auk_zerofill()`](https://cornelllabofornithology.github.io/auk/reference/auk_zerofill.md).
  This function will also work with an `auk_zerofill` object, in which
  case it will be converted to a data frame with
  [`collapse_zerofill()`](https://cornelllabofornithology.github.io/auk/reference/auk_zerofill.md).
  **Note that these data must for a single species**.

- min_obs:

  integer; minimum number of observations required for each site.

- max_obs:

  integer; maximum number of observations allowed for each site.

- annual_closure:

  logical; whether the entire year should be treated as the period of
  closure (the default). This can be useful, for example, if the data
  have been subset to a period of closure prior to calling
  `filter_repeat_visits()`.

- n_days:

  integer; number of days defining the temporal length of closure. If
  `annual_closure = TRUE` closure periods will be split at year
  boundaries. If `annual_closure = FALSE` the closure periods will
  ignore year boundaries.

- date_var:

  character; column name of the variable in `x` containing the date.
  This column should either be in `Date` format or convertible to `Date`
  format with [`as.Date()`](https://rdrr.io/r/base/as.Date.html).

- site_vars:

  character; names of one of more columns in `x` that define a site,
  typically the location (e.g. latitude/longitude) and observer ID.

- ll_digits:

  integer; the number of digits to round latitude and longitude to. If
  latitude and/or longitude are used as `site_vars`, it's usually best
  to round them prior to identifying sites, otherwise locations that are
  only slightly offset (e.g. a few centimeters) will be treated as
  different. This argument can also be used to group sites together that
  are close but not identical. Note that 1 degree of latitude is
  approximately 100 km, so the default value of 6 for `ll_digits` is
  equivalent to about 10 cm.

## Value

A `data.frame` filtered to only retain observations from sites with the
allowed number of observations within the period of closure. The results
will be sorted such that sites are together and in chronological order.
The following variables are added to the data frame:

- `site`: a unique identifier for each "site" corresponding to all the
  variables in `site_vars` and `closure_id` concatenated together with
  underscore separators.

- `closure_id`: a unique ID for each closure period. If
  `annual_closure = TRUE` this ID will include the year. If `n_days` is
  used an index given the number of blocks of `n_days` days since the
  earliest observation will be included. Note that in this case, there
  may be gaps in the IDs.

- `n_observations`: number of observations at each site after all
  filtering.

## Details

In addition to specifying the minimum and maximum number of observations
per site, users must specify the variables in the dataset that define a
"site". This is typically a combination of IDs defining the geographic
site and the unique observer (repeat visits are meant to be conducted by
the same observer). Finally, the closure period must be defined, which
is a period within which the population of the focal species can
reasonably be assumed to be closed. This can be done using a combination
of the `n_days` and `annual_closure` arguments.

## See also

Other modeling:
[`format_unmarked_occu()`](https://cornelllabofornithology.github.io/auk/reference/format_unmarked_occu.md)

## Examples

``` r
# read and zero-fill the ebd data
f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
f_smpl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
# data must be for a single species
ebd_zf <- auk_zerofill(x = f_ebd, sampling_events = f_smpl,
                       species = "Collared Kingfisher",
                       collapse = TRUE)
filter_repeat_visits(ebd_zf, n_days = 30)
#> # A tibble: 259 × 44
#>    site          closure_id n_observations checklist_id last_edited_date country
#>    <chr>         <chr>               <int> <chr>        <chr>            <chr>  
#>  1 L1055540_obs… 2012-2                  2 S49291608    2023-01-31 19:3… Singap…
#>  2 L1055540_obs… 2012-2                  2 S49291611    2025-10-08 20:3… Singap…
#>  3 L1361109_obs… 2012-0                 10 S9502932     2012-03-20 03:2… Singap…
#>  4 L1361109_obs… 2012-0                 10 S9598863     2024-05-08 04:1… Singap…
#>  5 L1361109_obs… 2012-0                 10 S9612576     2024-05-08 04:2… Singap…
#>  6 L1361109_obs… 2012-0                 10 S9628006     2024-05-08 04:2… Singap…
#>  7 L1361109_obs… 2012-0                 10 S9635686     2024-05-08 04:2… Singap…
#>  8 L1361109_obs… 2012-0                 10 S9640246     2024-05-08 04:2… Singap…
#>  9 L1361109_obs… 2012-0                 10 S9664008     2024-05-08 04:3… Singap…
#> 10 L1361109_obs… 2012-0                 10 S9671189     2024-05-08 04:3… Singap…
#> # ℹ 249 more rows
#> # ℹ 38 more variables: country_code <chr>, state <chr>, state_code <chr>,
#> #   county <chr>, county_code <chr>, iba_code <chr>, bcr_code <int>,
#> #   usfws_code <chr>, atlas_block <chr>, locality <chr>, locality_id <chr>,
#> #   locality_type <chr>, latitude <dbl>, longitude <dbl>,
#> #   observation_date <date>, time_observations_started <chr>,
#> #   observer_id <chr>, observer_orcid_id <chr>, …
```
