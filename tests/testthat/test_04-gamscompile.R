test_that("start.R --gamscompile config/scenario_config_AMT.csv works", {
  skipIfPreviousFailed()
  output <- localSystem2("Rscript", c("start.R", "--gamscompile", "config/scenario_config_AMT.csv"))
  printIfFailed(output)
  expectSuccessStatus(output)
})
