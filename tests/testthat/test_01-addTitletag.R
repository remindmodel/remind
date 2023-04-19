test_that("addTitletag works", {
  start <- c("0", "1", "1,test", "test")
  path_gdx_ref <- c("some.gdx", "A", "C", "other.gdx")
  scenarios <- data.frame(start, path_gdx_ref)
  row.names(scenarios) <- c("A", "B", "C", "D")

  path_gdx_ref <- c("some.gdx", "A-tag", "C-tag", "other.gdx")
  expected <- data.frame(start, path_gdx_ref)
  row.names(expected) <- c("A-tag", "B-tag", "C-tag", "D-tag")

  result <- addTitletag("tag", scenarios)
  expect_identical(expected, result)
})
