test_that("GAMS code follows the coding etiquette", {
  # have to run this via local_system2 so that it uses the renv, where gms
  # is actually installed.
  skip_if_previous_failed()
  output <- local_system2("Rscript", c("-e", "'invisible(gms::codeCheck(strict=TRUE))'"))
  print_if_failed(output)
  expect_success_status(output)
})
