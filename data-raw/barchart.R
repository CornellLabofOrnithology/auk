f_src <- "~/Downloads/ebird_SJ__2015_2025_1_12_barchart.txt"
f_dst <- "inst/extdata/barchart-sample.txt"
file.copy(f_src, f_dst, overwrite = TRUE)
