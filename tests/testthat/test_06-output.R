# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
test_that("output.R -> single -> reporting works", {
  skipIfFast()
  skipIfPreviousFailed()
  output <- localSystem2("Rscript", c("output.R", "comp=single", "output=reporting", "outputdir=output/testOneRegi",
                                      "slurmConfig='--qos=priority --mem=8000 --wait'"))
  printIfFailed(output)
  expectSuccessStatus(output)
  expect_true(file.exists("../../output/testOneRegi/REMIND_generic_testOneRegi.mif"))
})

test_that("output.R -> export -> xlsx_IIASA works", {
  skipIfFast()
  skipIfPreviousFailed()
  output <- localSystem2("Rscript", c("output.R", "project=TESTTHAT", "filename_prefix=TESTTHAT",
                                      "comp=export", "output=xlsx_IIASA", "outputdir=output/testOneRegi"))
  printIfFailed(output)
  exportfiles <- Sys.glob(file.path("..", "..", "output", "export", "*TESTTHAT*"))
  expect_true(length(exportfiles) >= 3)
  unlink(exportfiles)
  expectSuccessStatus(output)
})
