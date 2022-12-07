test_that("GAMS code follows the coding etiquette", {
  # have to run this via localSystem2 so that it uses the renv, where gms
  # is actually installed.
  skipIfPreviousFailed()
  output <- localSystem2("Rscript", c("-e", "'invisible(gms::codeCheck(strict=TRUE))'"))
  printIfFailed(output)
  expectSuccessStatus(output)
})
