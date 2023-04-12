test_that("start.R --gamscompile startgroup=AMT titletag=AMT config/scenario_config.csv works", {
  skipIfPreviousFailed()
  output <- localSystem2("Rscript",
                         c("start.R", "--gamscompile", "startgroup=AMT", "titletag=AMT", "config/scenario_config.csv"))
  printIfFailed(output)
  expectSuccessStatus(output)
})
