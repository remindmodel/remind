test_that("runGamsCompile works", {
  source("../../config/default.cfg")
  gmsfile <- tempfile(fileext = ".gms")
  writeLines(c("Parameter test 'a great test value' / 4 /;"), gmsfile)
  expect_true(runGamsCompile(gmsfile, cfg, interactive = FALSE))
  writeLines(c("meter test 'a great test value' / 4 /"), gmsfile)
  expect_false(runGamsCompile(gmsfile, cfg, interactive = FALSE))
})
