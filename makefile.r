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
file.copy(list.files(".", "README.*png", full.names = TRUE), "docs/")
dir.create("docs/hex-logo/")
file.copy("hex-logo/auk.svg", "docs/hex-logo/")
