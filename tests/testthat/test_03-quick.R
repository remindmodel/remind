test_that("start.R config/tests/scenario_config_quick.csv works", {
  skipIfPreviousFailed()
  output <- localSystem2("Rscript", c("start.R", "config/tests/scenario_config_quick.csv"))
  printIfFailed(output)
  expectSuccessStatus(output)
})
