test_that("path_gdx_list exists", {
  expect_true(exists("path_gdx_list"))
  expect_true("path_gdx" %in% names(path_gdx_list))
  expect_true("path_gdx_ref" %in% names(path_gdx_list))
  expect_true("path_gdx_carbonprice" %in% names(path_gdx_list))
  expect_true("path_gdx_bau" %in% names(path_gdx_list))
  expect_true("path_gdx_refpolicycost" %in% names(path_gdx_list))
})
