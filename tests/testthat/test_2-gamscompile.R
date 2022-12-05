test_that("start.R --gamscompile config/scenario_config_AMT.csv works", {
  skip_if_previous_failed()
  output <- local_system2("Rscript", c("start.R", "--gamscompile", "config/scenario_config_AMT.csv"))
  print_if_failed(output)
  expect_success_status(output)
})
