# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
csvfiles <- system("git ls-files ../../config/scenario_config*.csv ../../config/*/scenario_config*.csv", intern = TRUE)
if (length(csvfiles) == 0) {
  csvfiles <- Sys.glob(c(file.path("../../config/scenario_config*.csv"),
                         file.path("../../config", "*", "scenario_config*.csv")))
}
for (csvfile in csvfiles) {
  test_that(paste("perform readCheckScenarioConfig with", basename(csvfile)), {
    expect_no_warning(readCheckScenarioConfig(csvfile, remindPath = "../../", testmode = TRUE))
  })
}
test_that("readCheckScenarioConfig fails on error-loaden config", {
  csvfile <- tempfile(pattern = "scenario_config_a", fileext = ".csv")
  writeLines(c(";start;copyConfigFrom;c_budgetCO2;path_gdx;path_gdx_carbonprice;carbonprice;path_gdx_bau;path_gdx_ref;cm_startyear",
               "abc.loremipsumloremipsum@lorem&ipsumloremipsumloremipsumloremipsumloremipsumloremipsum_;0;;33;;;;;;",
               "PBS;1;glob;29;whitespace inside;whitespaceafter ;;;whatever;2020",
               "glob;0;missing_copyConfigFrom;33; ;nobreakspace	tab;;;;",
               "PBScopy;0;PBS;;;mustbedifferenttoPBS;;;;",
               "NA;1;;;;;notNDC_but_has_path_gdx_bau;PBS;;",
               "NDC_but_bau_missing;1;;;;;NDC;;;",
               "startyear_too_early;;;;;;;;PBS;2010"),
             con = csvfile, sep = "\n")
  w <- capture_warnings(m <- capture_messages(scenConf <- readCheckScenarioConfig(csvfile, remindPath = "../../", testmode = TRUE)))
  expect_match(w, "22 errors found", all = FALSE, fixed = TRUE)
  expect_match(w, "These titles are too long", all = FALSE, fixed = TRUE)
  expect_match(w, "These titles may be confused with regions", all = FALSE, fixed = TRUE)
  expect_match(w, "These titles contain illegal characters", all = FALSE, fixed = TRUE)
  expect_match(w, "\\.@&", all = FALSE)
  expect_match(w, "Outdated column names found that must not be used", all = FALSE, fixed = TRUE)
  expect_match(w, "contain whitespaces", all = FALSE, fixed = TRUE)
  expect_match(w, "scenario names indicated in copyConfigFrom column were not found", all = FALSE, fixed = TRUE)
  expect_match(w, "specify in copyConfigFrom column a scenario name defined below in the file", all = FALSE, fixed = TRUE)
  expect_match(w, "a reference gdx in 'path_gdx_bau'", all = FALSE, fixed = TRUE)
  expect_match(w, "Do not use 'NA' as scenario name", all = FALSE, fixed = TRUE)
  expect_match(w, "For module carbonprice.*notNDC_but_has_path_gdx_bau", all = FALSE, fixed = FALSE)
  expect_match(w, "Those scenarios link to a non-existing path_gdx: PBS, PBScopy", all = FALSE, fixed = TRUE)
  expect_match(w, "Those scenarios link to a non-existing path_gdx_ref: PBS, PBScopy", all = FALSE, fixed = TRUE)
  expect_match(w, "Those scenarios link to a non-existing path_gdx_refpolicycost: PBS, PBScopy", all = FALSE, fixed = TRUE)
  expect_match(w, "Those scenarios link to a non-existing path_gdx_carbonprice: PBS, glob, PBScopy", all = FALSE, fixed = TRUE)
  expect_match(w, "Those scenarios have cm_startyear earlier than their path_gdx_ref run, which is not supported: startyear_too_early", all = FALSE, fixed = TRUE)
  expect_match(m, "no column path_gdx_refpolicycost found, using path_gdx_ref instead", all = FALSE, fixed = TRUE)
  copiedFromPBS <- c("c_budgetCO2", "path_gdx", "path_gdx_ref")
  expect_identical(unlist(scenConf["PBS", copiedFromPBS]),
                   unlist(scenConf["PBScopy", copiedFromPBS]))
  expect_identical(scenConf["PBScopy", "path_gdx_carbonprice"], "mustbedifferenttoPBS")
  expect_identical(scenConf["PBS", "path_gdx_carbonprice"], "whitespaceafter")
})

test_that("copyConfigFrom copies settings properly", {
  scenConf <- data.frame(title = c("run1", "run2", "run3", "run4", "run5"),
                         A = c("A1", "A2", NA, "A4", "A5"),
                         copyConfigFrom = c(NA, "run1", "run2", NA, "run4"),
                         B = c(NA, NA, "B3", "B4", NA),
                         C = c("C1", NA, NA, "C4", NA),
                         row.names = 1)
  expected <- data.frame(title = c("run1", "run2", "run3", "run4", "run5"),
                         A = c("A1", "A2", "A2", "A4", "A5"),
                         copyConfigFrom = c(0, "run1", "run2", NA, "run4"),
                         B = c(NA, NA, "B3", "B4", "B4"),
                         C = c("C1", "C1", "C1", "C4", "C4"),
                         row.names = 1)
  actual <- copyConfigFrom(scenConf)
  expect_identical(actual, expected)
})
