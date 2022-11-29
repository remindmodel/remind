test_that("start.R works", {
  skip_if_fast()
  status <- local_system2("Rscript", c("start.R"))
  expect_equal(status, 0)
})
