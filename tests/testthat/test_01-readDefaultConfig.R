# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
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
