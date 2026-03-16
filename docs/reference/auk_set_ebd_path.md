# Set the path to EBD text files

Users of `auk` are encouraged to set the path to the directory
containing the eBird Basic Dataset (EBD) text files in the `EBD_PATH`
environment variable. All functions referencing the EBD or sampling
event data files will check in this directory to find the files, thus
avoiding the need to specify the full path every time. This will
increase the portability of your code. Use this function to set
`EBD_PATH` in your .Renviron file; it is also possible to manually edit
the file. This function first looks for for an .Renviron location
defined by `R_ENVIRON_USER`, then defaults to ~/.Renviron.

## Usage

``` r
auk_set_ebd_path(path, overwrite = FALSE)
```

## Arguments

- path:

  character; directory where the EBD text files are stored, e.g.
  `"/home/matt/ebd"`.

- overwrite:

  logical; should the existing `EBD_PATH` be overwritten if it has
  already been set in .Renviron.

## Value

Edits .Renviron, sets `EBD_PATH` for the current session, then returns
the EBD path invisibly.

## See also

Other paths:
[`auk_get_awk_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_get_awk_path.md),
[`auk_get_ebd_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_get_ebd_path.md),
[`auk_set_awk_path()`](https://cornelllabofornithology.github.io/auk/reference/auk_set_awk_path.md)

## Examples

``` r
if (FALSE) { # \dontrun{
auk_set_ebd_path("/home/matt/ebd")
} # }
```
