# Reference to eBird data file

Create a reference to an eBird Basic Dataset (EBD) file in preparation
for filtering using AWK.

## Usage

``` r
auk_ebd(file, file_sampling, sep = "\t")
```

## Arguments

- file:

  character; input file. If file is not found as specified, it will be
  looked for in the directory specified by the `EBD_PATH` environment
  variable.

- file_sampling:

  character; optional input sampling event data (i.e. checklists) file,
  required if you intend to zero-fill the data to produce a
  presence-absence data set. This file consists of just effort
  information for every eBird checklist. Any species not appearing in
  the EBD for a given checklist is implicitly considered to have a count
  of 0. This file should be downloaded at the same time as the basic
  dataset to ensure they are in sync. If file is not found as specified,
  it will be looked for in the directory specified by the `EBD_PATH`
  environment variable.

- sep:

  character; the input field separator, the eBird data are tab separated
  so this should generally not be modified. Must only be a single
  character and space delimited is not allowed since spaces appear in
  many of the fields.

## Value

An `auk_ebd` object storing the file reference and the desired filters
once created with other package functions.

## Details

eBird data can be downloaded as a tab-separated text file from the
[eBird website](http://ebird.org/ebird/data/download) after submitting a
request for access. As of February 2017, this file is nearly 150 GB
making it challenging to work with. If you're only interested in a
single species or a small region it is possible to submit a custom
download request. This approach is suggested to speed up processing
time.

There are two potential pathways for preparing eBird data. Users wishing
to produce presence only data, should download the [eBird Basic
Dataset](http://ebird.org/ebird/data/download/) and reference this file
when calling `auk_ebd()`. Users wishing to produce zero-filled, presence
absence data should additionally download the sampling event data file
associated with the basic dataset This file contains only checklist
information and can be used to infer absences. The sampling event data
file should be provided to `auk_ebd()` via the `file_sampling` argument.
For further details consult the vignettes.

## See also

Other objects:
[`auk_sampling()`](https://cornelllabofornithology.github.io/auk/reference/auk_sampling.md)

## Examples

``` r
# get the path to the example data included in the package
# in practice, provide path to ebd, e.g. f <- "data/ebd_relFeb-2018.txt
f <- system.file("extdata/ebd-sample.txt", package = "auk")
auk_ebd(f)
#> Input 
#>   EBD: /private/var/folders/wf/957fnnnd127fsdkxc1dtmc2m0000gp/T/RtmppZXGo8/temp_libpath917c7939de6e/auk/extdata/ebd-sample.txt 
#> 
#> Output 
#>   Filters not executed
#> 
#> Filters 
#>   Species: all
#>   Countries: all
#>   States: all
#>   Counties: all
#>   BCRs: all
#>   Bounding box: full extent
#>   Years: all
#>   Date: all
#>   Start time: all
#>   Last edited date: all
#>   Protocol: all
#>   Project code: all
#>   Duration: all
#>   Distance travelled: all
#>   Records with breeding codes only: no
#>   Exotic Codes: all
#>   Complete checklists only: no
# to produce zero-filled data, provide a checklist file
f_ebd <- system.file("extdata/zerofill-ex_ebd.txt", package = "auk")
f_cl <- system.file("extdata/zerofill-ex_sampling.txt", package = "auk")
auk_ebd(f_ebd, file_sampling = f_cl)
#> Input 
#>   EBD: /private/var/folders/wf/957fnnnd127fsdkxc1dtmc2m0000gp/T/RtmppZXGo8/temp_libpath917c7939de6e/auk/extdata/zerofill-ex_ebd.txt 
#>   Sampling events: /private/var/folders/wf/957fnnnd127fsdkxc1dtmc2m0000gp/T/RtmppZXGo8/temp_libpath917c7939de6e/auk/extdata/zerofill-ex_sampling.txt 
#> 
#> Output 
#>   Filters not executed
#> 
#> Filters 
#>   Species: all
#>   Countries: all
#>   States: all
#>   Counties: all
#>   BCRs: all
#>   Bounding box: full extent
#>   Years: all
#>   Date: all
#>   Start time: all
#>   Last edited date: all
#>   Protocol: all
#>   Project code: all
#>   Duration: all
#>   Distance travelled: all
#>   Records with breeding codes only: no
#>   Exotic Codes: all
#>   Complete checklists only: no
```
