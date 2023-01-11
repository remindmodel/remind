test_that("environment is suitable for coupled tests", {
  skipIfFast()
  skipIfPreviousFailed()
  # magpie needs to be cloned by the user before running coupled tests
  expect_true(dir.exists("../../../magpie"))
  # coupled tests need slurm
  expect_true(isSlurmAvailable())
})

test_that("runs coupled to MAgPIE work", {
  skipIfFast()
  skipIfPreviousFailed()
  output <- localSystem2("Rscript", c("start_bundle_coupled.R", "config/tests/scenario_config_shortCascade.csv"),
                         env = "R_PROFILE_USER=.snapshot.Rprofile")
  printIfFailed(output)
  expectSuccessStatus(output)
})
