# Return EBD data path

Returns the environment variable `EBD_PATH`, which users are encouraged
to set to the directory that stores the eBird Basic Dataset (EBD) text
files.

## Usage

``` r
auk_get_ebd_path()
```

## Value

The path stored in the `EBD_PATH` environment variable.

## See also

Other paths:
[`auk_get_awk_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_get_awk_path.md),
[`auk_set_awk_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_set_awk_path.md),
[`auk_set_ebd_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_set_ebd_path.md)

## Examples

``` r
auk_get_ebd_path()
#> [1] "/Users/mes335/data/ebird"
```
