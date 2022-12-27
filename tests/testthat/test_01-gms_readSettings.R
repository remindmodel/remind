test_that("readSettings exists without warning", {
  expect_warning(gms::readSettings("../../main.gms"), regexp = NA)
})
