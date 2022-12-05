test_that("start.R config/tests/scenario_config_quick.csv works", {
  cat("Tests take a couple of minutes, please be patient.")
  skip_if_previous_failed()
  output <- local_system2("Rscript", c("start.R", "config/tests/scenario_config_quick.csv"))
  print_if_failed(output)
  expect_success_status(output)
})
