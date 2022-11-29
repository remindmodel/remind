test_that("start.R works", {
  skip_if_fast()
  status <- local_system2("Rscript", c("start.R", "config/tests/scenario_config_default.csv"))
  expect_equal(status, 0)
})
