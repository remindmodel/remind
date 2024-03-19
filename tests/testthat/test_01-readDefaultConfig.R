test_that("readDefaultConfig works", {
  expect_no_warning(cfg <- gms::readDefaultConfig("../.."))
  # make sure that no identical names are used to guarantee unique matching of scenario_config data
  expect_identical(intersect(names(cfg), names(cfg$gms)), character(0))
  # make sure there is no cm_test and c_test simultaneously
  shortnames <- tolower(gsub("^[a-zA-Z][a-zA-Z]?_", "", names(cfg$gms)))
  duplicates <- names(cfg$gms)[duplicated(shortnames) | duplicated(shortnames, fromLast = TRUE)]
  expect_equal(duplicates, character(0),
               label = paste("Duplicated variable names:", paste(duplicates, collapse = ", ")))
})
