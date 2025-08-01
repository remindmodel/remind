# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
test_that("start.R --gamscompile startgroup=AMT config/scenario_config.csv works", {
  unlink(paste0("../../output/gamscompile/*TESTTHAT", c(".gms", ".lst")))
  csvfile <- "config/scenario_config.csv"
  titletag <- paste0("titletag=TESTTHAT-", gsub(".csv$", "", basename(csvfile)))
  testthat::with_mocked_bindings({
    skipIfPreviousFailed()
    output <- localSystem2("Rscript",
                           c("start.R", "--gamscompile", "startgroup=compileInTests", titletag, csvfile))
    printIfFailed(output)
    expectSuccessStatus(output)
    },
    getLine = function() stop("getLine should not called."),
    .package = "gms"
  )
  unlink("../../*TESTTHAT.RData")
})

test_that("start.R --gamscompile works on all configs and scenarios", {
  skipIfFast()
  skipIfPreviousFailed()
  csvfiles <- system("git ls-files ../../config/scenario_config*.csv ../../config/*/scenario_config*.csv", intern = TRUE)
  if (length(csvfiles) == 0) {
    csvfiles <- Sys.glob(c(file.path("../../config/scenario_config*.csv"),
                           file.path("../../config", "*", "scenario_config*.csv")))
  }
  csvfiles <- normalizePath(grep("scenario_config_coupled.*", csvfiles, invert = TRUE, value = TRUE))
  expect_true(length(csvfiles) > 0)
  testthat::with_mocked_bindings(
    for (csvfile in csvfiles) {
      if (grepl("scenario_config_PyPSA|scenario_config_21_EU11_ARIADNE", csvfile)) next
      test_that(paste("perform start.R --gamscompile with", basename(csvfile)), {
        titletag <- paste0("titletag=TESTTHAT-", gsub(".csv$", "", basename(csvfile)))
        output <- localSystem2("Rscript",
                             c("start.R", "--gamscompile", "startgroup=*", titletag, csvfile))
        printIfFailed(output)
        expectSuccessStatus(output)
      })
    },
    getLine = function() stop("getLine should not called."),
    .package = "gms"
  )
  unlink("../../*TESTTHAT.RData")
})
