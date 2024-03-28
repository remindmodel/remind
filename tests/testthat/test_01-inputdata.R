test_that("Are all input data files present?", {
  missinginput <- missingInputData(path = "../..")
  if (length(missinginput) > 0) {
    lockID <- gms::model_lock(folder = "../..")
    updateInputData(cfg = gms::readDefaultConfig("../.."), remindPath = "../..")
    resetCESfile(remindPath = "../..")
    gms::model_unlock(lockID)
    missinginput <- missingInputData(path = "../..")
    if (length(missinginput) > 0) {
      warning("Missing input files: ", paste(missinginput, collapse = ", "))
    }
  }
  expect_true(length(missinginput) == 0)
})
