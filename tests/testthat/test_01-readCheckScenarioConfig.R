csvfiles <- Sys.glob(c(file.path("../../config/scenario_config*.csv"),
                       file.path("../../config","*","scenario_config*.csv")))
for (csvfile in csvfiles) {
  test_that(paste("perform readCheckScenarioConfig with", gsub("../../config/", "", csvfile)), {
    # regexp = NA means: expect no warning
    expect_warning(readCheckScenarioConfig(csvfile, remindPath = "../../", testmode = TRUE), regexp = NA)
  })
}
