# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
test_that("path_gdx_list exists", {
  expect_true(exists("path_gdx_list"))
  expect_true("path_gdx" %in% names(path_gdx_list))
  expect_true("path_gdx_ref" %in% names(path_gdx_list))
  expect_true("path_gdx_carbonprice" %in% names(path_gdx_list))
  expect_true("path_gdx_bau" %in% names(path_gdx_list))
  expect_true("path_gdx_refpolicycost" %in% names(path_gdx_list))
})
