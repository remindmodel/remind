# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
test_that("selectSettings works with a startgroup", {
  title <- c("A", "B", "C", "D")
  start <- c("0", "1", "1,test", "test")
  settings <- data.frame(title, start)
  expected <- settings[c(FALSE, FALSE, TRUE, TRUE), ]
  result <- selectScenarios(settings = settings, interactive = FALSE, startgroup = "test")
  expect_identical(expected, result)
})

test_that("selectSettings works without a startgroup", {
  title <- c("A", "B", "C", "D")
  start <- c(0, 1, 1, 0)
  settings <- data.frame(title, start)
  expected <- settings[c(FALSE, TRUE, TRUE, FALSE), ]
  expect_identical(expected, selectScenarios(settings = settings, interactive = FALSE, startgroup = "1"))
})
