# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
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
                           c("start.R", "--gamscompile", "startgroup=AMT", titletag, csvfile))
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
  csvfiles <- normalizePath(grep("^scenario_config_coupled.*", csvfiles, invert = TRUE, value = TRUE))
  skipfiles <- c("scenario_config_21_EU11_ECEMF",
                 "scenario_config_21_EU11_ARIADNE",
                 "scenario_config_21_EU11_SSPSDP",
                 "scenario_config_21_EU11_Fit_for_55_sensitivity",
                 "scenario_config_EDGE-T_NDC_NPi_pkbudget",
                 "scenario_config_NAVIGATE_300",
                 "scenario_config_tradeCap_standalone",
                 "scenario_config_SHAPE",
                 "scenario_config_GCS")
  csvfiles <- grep(paste(skipfiles, collapse = "|"), csvfiles, invert = TRUE, value = TRUE)
  expect_true(length(csvfiles) > 0)
  testthat::with_mocked_bindings(
    for (csvfile in csvfiles) {
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
