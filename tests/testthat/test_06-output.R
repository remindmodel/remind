# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
skipIfFast()
skipIfPreviousFailed()

test_that("output.R -> single -> reporting works", {
  output <- localSystem2("Rscript", c("output.R", "comp=single", "output=reporting", "outputdir=output/testOneRegi",
                                      "slurmConfig='--qos=priority --mem=8000 --wait'"))
  printIfFailed(output)
  expectSuccessStatus(output)
  expect_true(file.exists("../../output/testOneRegi/REMIND_generic_testOneRegi.mif"))
})

test_that("output.R -> export -> xlsx_IIASA works", {
  exportfiles <- Sys.glob(file.path("..", "..", "output", "export", "*TESTTHAT*"))
  unlink(exportfiles)
  output <- localSystem2("Rscript", c("output.R", "project=TESTTHAT", "filename_prefix=TESTTHAT",
                                      "comp=export", "output=xlsx_IIASA", "outputdir=output/testOneRegi"))
  printIfFailed(output)
  exportfiles <- Sys.glob(file.path("..", "..", "output", "export", "*TESTTHAT*"))
  expect_true(sum(grepl("REMIND_TESTTHAT.*xlsx$", exportfiles)) == 1)
  expect_true(sum(grepl("REMIND_TESTTHAT.*log$", exportfiles)) == 1)
  expect_true(sum(grepl("REMIND_TESTTHAT.*checkSummations\\.csv$", exportfiles)) == 1)
  expect_true(sum(grepl("REMIND_TESTTHAT.*checkSummations.*pdf$", exportfiles)) == 1)
  expectSuccessStatus(output)
})

test_that("cleanup output.R", {
  skipIfPreviousFailed()
  exportfiles <- Sys.glob(file.path("..", "..", "output", "export", "*TESTTHAT*"))
  unlink(exportfiles)
})
