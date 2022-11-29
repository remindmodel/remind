test_that("GAMS code follows the coding etiquette", {
  # have to run this via local_system2 so that it uses the renv, where gms
  # is actually installed.
  status <- local_system2("Rscript", c("-e", "'invisible(gms::codeCheck(strict=TRUE))'"))
  expect_equal(status, 0)
})
