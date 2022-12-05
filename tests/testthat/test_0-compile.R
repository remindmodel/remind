test_that("remind compiles", {
  skip_if_previous_failed()
  output <- local_system2("Rscript", c("start.R", "config/tests/scenario_config_compile.csv"))
  print_if_failed(output)
  expect_success_status(output)
})
