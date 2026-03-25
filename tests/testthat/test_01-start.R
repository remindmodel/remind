# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
test_that("start.R fails on missing path_gdx* files", {
  csvfile <- tempfile(pattern = "scenario_config_a", fileext = ".csv")
  writeLines(c(";start;slurmConfig;path_gdx;path_gdx_carbonprice",
               "somearbitraryruntitle;1;8;whateverstring.noonewilluse_;another.unusedstring_"),
               con = csvfile, sep = "\n")
  output <- localSystem2("Rscript", c("start.R", "--test", csvfile))
  unlink("../../somearbitraryruntitle.RData")
  expect_true(any(grepl("2 errors were identified", output)))
  expectFailStatus(output)
})

test_that("start.R --test startgroup=AMT titletag=AMT config/scenario_config.csv works", {
  testthat::with_mocked_bindings({
    skipIfPreviousFailed()
    output <- localSystem2("Rscript",
                           c("start.R", "--test", "slurmConfig=16", "startgroup=AMT", "titletag=TESTTHAT", "config/scenario_config.csv"))
    printIfFailed(output)
    expectSuccessStatus(output)
    expect_false(any(grepl("Waiting for.* NA( |$)", output)))
    },
    getLine = function() stop("getLine should not called."),
    .package = "gms"
  )
  unlink("../../*TESTTHAT.RData")
})

test_that("start.R --test succeeds on all configs", {
  skipIfFast()
  skipIfPreviousFailed()
  csvfiles <- system("git ls-files ../../config/scenario_config*.csv ../../config/*/scenario_config*.csv", intern = TRUE)
  if (length(csvfiles) == 0) {
    csvfiles <- Sys.glob(c(file.path("../../config/scenario_config*.csv"),
                           file.path("../../config", "*", "scenario_config*.csv")))
  }
  csvfiles <- normalizePath(grep("scenario_config_magpie", csvfiles, invert = TRUE, value = TRUE))
  expect_true(length(csvfiles) > 0)
  testthat::with_mocked_bindings(
    for (csvfile in csvfiles) {
      test_that(paste("perform start.R --test with", basename(csvfile)), {
        output <- localSystem2("Rscript",
                             c("start.R", "--test", "slurmConfig=16", "startgroup=*", "titletag=TESTTHAT", csvfile))
        printIfFailed(output)
        expectSuccessStatus(output)
        expect_false(any(grepl("Waiting for.* NA( |$)", output)))
      })
    },
    getLine = function() stop("getLine should not called."),
    .package = "gms"
  )
  unlink("../../*TESTTHAT.RData")
})
