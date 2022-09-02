# clean up
unlink(list.files("man", full.names = TRUE))
devtools::clean_vignettes()
pkgdown::clean_site()

# rebuild docs and install
devtools::document()
pak::pkg_install(".", ask = FALSE)

# local tests and checks
devtools::test()
devtools::check()

# vignettes, readme, site
dir.create("man/figures/")
file.copy("cheatsheet/auk-cheatsheet.png", "man/figures/auk-cheatsheet.png")
rmarkdown::render("README.Rmd")
#devtools::build_vignettes()
pkgdown::check_pkgdown()
pkgdown::build_site()

# checks
devtools::check_win_devel()
devtools::check_win_release()
