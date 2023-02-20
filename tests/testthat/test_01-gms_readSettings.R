test_that("readSettings exits without warning", {
  expect_warning(gms::readSettings("../../main.gms"), regexp = NA)
})

test_that("standalone models have consistent settings definition", {
  skip("standalone models aren't consistent at the moment")
  expect_warning(gms::readSettings("../../standalone/trade/trade.gms"), regexp = NA)
  expect_warning(gms::readSettings("../../standalone/MOFEX/MOFEX.gms"), regexp = NA)
})
