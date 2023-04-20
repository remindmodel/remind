# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
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
