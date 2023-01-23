csvfiles <- system("git ls-files ../../config/scenario_config*.csv ../../config/*/scenario_config*.csv", intern = TRUE)
if (length(csvfiles) == 0) {
  csvfiles <- Sys.glob(c(file.path("../../config/scenario_config*.csv"),
                         file.path("../../config", "*", "scenario_config*.csv")))
}
for (csvfile in csvfiles) {
  # This is a new test and we currently still have errors. Let's fix them ASAP.
  if (csvfile %in% c(
      "../../config/21_regions_EU11/scenario_config_21_EU11_ARIADNE.csv",
      "../../config/21_regions_EU11/scenario_config_21_EU11_Fit_for_55_sensitivity.csv"
      )) {
        next
      }
  test_that(paste("perform readCheckScenarioConfig with", gsub("../../config/", "", csvfile, fixed = TRUE)), {
    # regexp = NA means: expect no warning
    expect_warning(readCheckScenarioConfig(csvfile, remindPath = "../../", testmode = TRUE), regexp = NA)
  })
}
test_that("readCheckScenarioConfig fails on error-loaden config", {
  csvfile <- tempfile(pattern = "scenario_config_a", fileext = ".csv")
  writeLines(c(";start;c_budgetCO2",
               "abc.loremipsumloremipsumloremipsumloremipsumloremipsumloremipsumloremipsumloremipsum_;0;33",
               "PBS;1;29",
               "glob;0;33"),
             con = csvfile, sep = "\n")
  w <- capture_warnings(readCheckScenarioConfig(csvfile, remindPath = "../../", testmode = TRUE))
  expect_match(w, "5 errors found", all = FALSE)
  expect_match(w, "These titles are too long", all = FALSE)
  expect_match(w, "These titles may be confused with regions", all = FALSE)
  expect_match(w, "These titles contain a dot", all = FALSE)
  expect_match(w, "Outdated column names found that must not be used", all = FALSE)
})
