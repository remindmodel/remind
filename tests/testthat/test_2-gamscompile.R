test_that("start.R --gamscompile config/scenario_config_AMT.csv works", {
  status <- local_system2("Rscript", c("start.R", "--gamscompile", "config/scenario_config_AMT.csv"))
  expect_equal(status, 0)
})
