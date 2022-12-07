test_that("remind compiles", {
  skipIfPreviousFailed()
  output <- localSystem2("Rscript", c("start.R", "config/tests/scenario_config_compile.csv"))
  printIfFailed(output)
  expectSuccessStatus(output)
})
