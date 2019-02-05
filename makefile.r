unlink(list.files("man", full.names = TRUE))
devtools::clean_vignettes()
pkgdown::clean_site()

devtools::document()

devtools::install_local(force = TRUE)

devtools::test()
devtools::check()

rmarkdown::render("README.Rmd")
devtools::build_vignettes()
pkgdown::build_site()