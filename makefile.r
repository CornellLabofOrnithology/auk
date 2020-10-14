  # clean up
  unlink(list.files("man", full.names = TRUE))
  devtools::clean_vignettes()
  pkgdown::clean_site()
  
  # rebuild docs and install
  devtools::document()
  devtools::install_local(force = TRUE)
  
  # local tests and checks
  devtools::test()
  devtools::check()
  
  # vignettes, readme, site
  rmarkdown::render("README.Rmd")
  devtools::build_vignettes()
  pkgdown::build_site()
  dir.create("docs/cheatsheet/")
  file.copy("cheatsheet/auk-cheatsheet.png", "docs/cheatsheet/auk-cheatsheet.png")
  
# checks
devtools::check_win_devel()
devtools::check_win_release()
rhub::check_for_cran()
