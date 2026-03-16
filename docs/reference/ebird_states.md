# eBird States

A data frame of state codes used by eBird. These codes are 4 to 6
characters, consisting of two parts, the 2-letter ISO country code and a
1-3 character state code, separated by a dash. For example, `"US-NY"`
corresponds to New York State in the United States. These state codes
are required to filter by state using
[`auk_state()`](https://cornelllabofornithology.github.io/auk/reference/auk_state.md).

## Usage

``` r
ebird_states
```

## Format

A data frame with four variables and 3,145 rows:

- `country`: short form of English country name.

- `country_code`: 2-letter ISO country code.

- `state`: state name.

- `state_code`: 4 to 6 character state code.

## Details

Note that some countries are not broken into states in eBird and
therefore do not appear in this data frame.

## See also

Other data:
[`bcr_codes`](https://cornelllabofornithology.github.io/auk/reference/bcr_codes.md),
[`ebird_taxonomy`](https://cornelllabofornithology.github.io/auk/reference/ebird_taxonomy.md),
[`valid_protocols`](https://cornelllabofornithology.github.io/auk/reference/valid_protocols.md)
