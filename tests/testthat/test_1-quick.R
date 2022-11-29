test_that("start.R config/scenario_config_quick.csv works", {
  status <- local_system2("Rscript", c("start.R", "config/tests/scenario_config_quick.csv"))
  expect_equal(status, 0)
})
