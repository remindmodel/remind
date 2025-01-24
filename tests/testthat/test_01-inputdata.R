# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
test_that("Are all input data files present?", {
  missinginput <- missingInputData(path = "../..")
  if (length(missinginput) > 0) {
    lockID <- gms::model_lock(folder = "../..")
    w <- capture_warnings(updateInputData(cfg = gms::readDefaultConfig("../.."), remindPath = "../.."))
    # ignore warning about missing historical.mif, raise warning if there were other warnings
    ignore <- "File historical.mif seems to be missing!"
    w <- setdiff(w, ignore)
    if (length(w) > 0) {
      warning(paste0("'updateInputData' raised the following warnings\n", paste(w, collapse = "\n")))
    }
    gms::model_unlock(lockID)
    missinginput <- missingInputData(path = "../..")
    # remove historical.mif since it is optional
    missinginput <- grep("historical.mif", missinginput, invert = TRUE, value = TRUE)
    if (length(missinginput) > 0) {
      warning("Missing input files: ", paste(missinginput, collapse = ", "))
    }
  }
  expect_true(length(missinginput) == 0)
})
