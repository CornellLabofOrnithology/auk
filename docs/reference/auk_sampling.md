# Reference to eBird sampling event file

Create a reference to an eBird sampling event file in preparation for
filtering using AWK. For working with the sightings data use
[`auk_ebd()`](https://cornelllabofornithology.github.io/auk/reference/auk_ebd.md),
only use `auk_sampling()` if you intend to only work with
checklist-level data.

## Usage

``` r
auk_sampling(file, sep = "\t")
```

## Arguments

- file:

  character; input sampling event data file, which contains checklist
  data from eBird.

- sep:

  character; the input field separator, the eBird data are tab separated
  so this should generally not be modified. Must only be a single
  character and space delimited is not allowed since spaces appear in
  many of the fields.

## Value

An `auk_sampling` object storing the file reference and the desired
filters once created with other package functions.

## Details

eBird data can be downloaded as a tab-separated text file from the
[eBird website](http://ebird.org/ebird/data/download) after submitting a
request for access. In the eBird Basic Dataset (EBD) each row
corresponds to a observation of a single bird species on a single
checklist, while the sampling event data file contains a single row for
every checklist. This function creates an R object to reference only the
sampling data.

## See also

Other objects:
[`auk_ebd()`](https://cornelllabofornithology.github.io/auk/reference/auk_ebd.md)

## Examples

``` r
# get the path to the example data included in the package
# in practice, provide path to the sampling event data
# e.g. f <- "data/ebd_sampling_relFeb-2018.txt"
f <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
auk_sampling(f)
#> Input 
#>   Sampling events: /private/var/folders/wf/957fnnnd127fsdkxc1dtmc2m0000gp/T/RtmpKUZwru/temp_libpath46c66a2d6343/auk/extdata/zerofill-ex_sampling.txt 
#> 
#> Output 
#>   Filters not executed
#> 
#> Filters 
#>   Countries: all
#>   States: all
#>   Counties: all
#>   Bounding box: full extent
#>   Years: all
#>   Date: all
#>   Start time: all
#>   Last edited date: all
#>   Protocol: all
#>   Project code: all
#>   Duration: all
#>   Distance travelled: all
#>   Complete checklists only: no
```
