csvfiles <- system("git ls-files ../../config/scenario_config*.csv ../../config/*/scenario_config*.csv", intern = TRUE)
if (length(csvfiles) == 0) {
  csvfiles <- Sys.glob(c(file.path("../../config/scenario_config*.csv"),
                         file.path("../../config", "*", "scenario_config*.csv")))
}
for (csvfile in csvfiles) {
  test_that(paste("perform readCheckScenarioConfig with", gsub("../../config/", "", csvfile, fixed = TRUE)), {
    # regexp = NA means: expect no warning
    expect_warning(readCheckScenarioConfig(csvfile, remindPath = "../../", testmode = TRUE), regexp = NA)
  })
}
test_that("readCheckScenarioConfig fails on error-loaden config", {
  csvfile <- tempfile(pattern = "scenario_config_a", fileext = ".csv")
  writeLines(c(";start;copyConfigFrom;c_budgetCO2;path_gdx;path_gdx_carbonprice",
               "abc.loremipsumloremipsum@lorem&ipsumloremipsumloremipsumloremipsumloremipsumloremipsum_;0;;33;;",
               "PBS;1;glob;29; whitespacebefore;whitespaceafter ",
               "glob;0;missing_copyConfigFrom;33; ;nobreakspace	tab"),
             con = csvfile, sep = "\n")
  w <- capture_warnings(readCheckScenarioConfig(csvfile, remindPath = "../../", testmode = TRUE))
  expect_match(w, "11 errors found", all = FALSE)
  expect_match(w, "These titles are too long", all = FALSE)
  expect_match(w, "These titles may be confused with regions", all = FALSE)
  expect_match(w, "These titles contain illegal characters", all = FALSE)
  expect_match(w, "\\.@&", all = FALSE)
  expect_match(w, "Outdated column names found that must not be used", all = FALSE)
  expect_match(w, "contain whitespaces", all = FALSE)
  expect_match(w, "following scenario names indicated in copyConfigFrom column were not found", all = FALSE)
  expect_match(w, "following scenarios references in copyConfigFrom column a scenario defined only later", all = FALSE)
})
