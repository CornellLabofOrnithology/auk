# rebuild docs and install
devtools::document()
pak::local_install(ask = FALSE, dependencies = TRUE)

# local tests and checks
devtools::test()
tools:::.check_package_datasets(".")

# vignettes, readme, site
file.copy("cheatsheet/auk-cheatsheet.png", "man/figures/auk-cheatsheet.png")
devtools::build_readme()
pkgdown::check_pkgdown()
pkgdown::build_site()
unlink(c("docs/CLAUDE.md", "docs/CLAUDE.html"))

# checks
devtools::check()
devtools::check_win_devel()
devtools::check_win_release()

# revdeps
revdepcheck::revdep_check(num_workers = 4)
