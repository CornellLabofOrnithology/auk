# clean up
unlink(list.files("man", full.names = TRUE))
devtools::clean_vignettes()
pkgdown::clean_site()

# rebuild docs and install
devtools::document()
remotes::install_local(force = TRUE)

# local tests and checks
devtools::test()
tools:::.check_package_datasets(".")

# vignettes, readme, site
dir.create("man/figures/")
file.copy("cheatsheet/auk-cheatsheet.png", "man/figures/auk-cheatsheet.png")
devtools::build_readme()
#devtools::build_vignettes()
pkgdown::check_pkgdown()
pkgdown::build_site()

# checks
devtools::check()
devtools::check_win_devel()
devtools::check_win_release()
