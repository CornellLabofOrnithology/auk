# Set a custom path to AWK executable

If AWK has been installed in a non-standard location, the environment
variable `AWK_PATH` must be set to specify the location of the
executable. Use this function to set `AWK_PATH` in your .Renviron file.
**Most users should NOT set `AWK_PATH`, only do so if you have installed
AWK in non-standard location and `auk` cannot find it.** This function
first looks for for an .Renviron location defined by `R_ENVIRON_USER`,
then defaults to ~/.Renviron.

## Usage

``` r
auk_set_awk_path(path, overwrite = FALSE)
```

## Arguments

- path:

  character; path to the AWK executable on your system, e.g.
  `"C:/cygwin64/bin/gawk.exe"` or `"/usr/bin/awk"`.

- overwrite:

  logical; should the existing `AWK_PATH` be overwritten if it has
  already been set in .Renviron.

## Value

Edits .Renviron, sets `AWK_PATH` for the current session, then returns
the EBD path invisibly.

## See also

Other paths:
[`auk_get_awk_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_get_awk_path.md),
[`auk_get_ebd_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_get_ebd_path.md),
[`auk_set_ebd_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_set_ebd_path.md)

## Examples

``` r
if (FALSE) { # \dontrun{
auk_set_awk_path("/usr/bin/awk")
} # }
```
