# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
test_that("readSettings exits without warning", {
  expect_no_warning(gms::readSettings("../../main.gms"))
})

test_that("standalone models have consistent settings definition", {
  skip("standalone models aren't consistent at the moment")
  expect_no_warning(gms::readSettings("../../standalone/trade/trade.gms"))
  expect_no_warning(gms::readSettings("../../standalone/MOFEX/MOFEX.gms"))
})
