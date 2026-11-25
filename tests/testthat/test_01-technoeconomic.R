# |  (C) 2006-2026 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
test_that("core/input/f_technoeconomic.csv can be generated from POSTED", {
  source("../../scripts/input/create_input_for_technoeconomic.R", local = TRUE)
  # failing to sync, lock or fetch raises and fails the test; a clean call
  # means the csv is current
  expect_no_error(create_input_for_technoeconomic("../.."))
})
