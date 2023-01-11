csvfiles <- Sys.glob(c(file.path("../../config/scenario_config*.csv"),
                       file.path("../../config","*","scenario_config*.csv")))
for (csvfile in csvfiles) {
  test_that(paste("perform readCheckScenarioConfig with", gsub("../../config/", "", csvfile)), {
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
  w <- capture_warnings(expect_error(readCheckScenarioConfig(csvfile, remindPath = "../../", testmode = TRUE),
                                     "6 errors found"))
  expect_match(w, "These titles are too long", all = FALSE)
  expect_match(w, "These titles may be confused with regions", all = FALSE)
  expect_match(w, "These titles contain a dot", all = FALSE)
  expect_match(w, "These titles end with _", all = FALSE)
  expect_match(w, "Outdated column names found that must not be used", all = FALSE)
})
