test_that("start.R works", {
  skip_if_fast()
  skip_if_previous_failed()
  output <- local_system2("Rscript", c("start.R", "config/tests/scenario_config_default.csv"))
  print_if_failed(output)
  expect_success_status(output)
})
