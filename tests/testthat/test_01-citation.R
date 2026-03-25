test_that("CITATION.cff can be parsed", {
  expect_no_warning(yaml::read_yaml("../../CITATION.cff"))
})
