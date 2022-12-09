test_that("start.R works", {
  skipIfFast()
  skipIfPreviousFailed()
  output <- localSystem2("Rscript", c("start.R", "config/tests/scenario_config_default.csv"))
  printIfFailed(output)
  expectSuccessStatus(output)
})
