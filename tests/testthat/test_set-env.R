test_that("auk_set_ebd_path()", {
  renv <- file.path(temp_dir, ".Renviron")
  Sys.setenv(R_ENVIRON_USER=renv)
  returned_path <- auk_set_ebd_path(temp_dir)
  expect_equal(returned_path, normalizePath(temp_dir))
  expect_equal(returned_path, Sys.getenv("EBD_PATH"))
})
