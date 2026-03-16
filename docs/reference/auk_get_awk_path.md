# OS specific path to AWK executable

Return the OS specific path to AWK (e.g. `"C:/cygwin64/bin/gawk.exe"` or
`"/usr/bin/awk"`), or highlights if it's not installed. To manually set
the path to AWK, set the `AWK_PATH` environment variable in your
`.Renviron` file, which can be accomplished with the helper function
`auk_set_awk_path(path)`.

## Usage

``` r
auk_get_awk_path()
```

## Value

Path to AWK or `NA` if AWK wasn't found.

## See also

Other paths:
[`auk_get_ebd_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_get_ebd_path.md),
[`auk_set_awk_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_set_awk_path.md),
[`auk_set_ebd_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_set_ebd_path.md)

## Examples

``` r
auk_get_awk_path()
#> [1] "/usr/bin/awk"
```
