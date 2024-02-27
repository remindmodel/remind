test_that("Are all input data files present?", {
  missinginput <- missingInputData(path = "../..")
  if (length(missinginput) > 0) {
    updateInputData(cfg = gms::readDefaultConfig("../.."), remindPath = "../..")
    missinginput <- missingInputData(path = "../..")
    if (length(missinginput) > 0) {
      warning("Missing input files: ", paste(missinginput, collapse = ", "))
    }
  }
  expect_true(length(missinginput) == 0)
})
