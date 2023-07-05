# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
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
  # for a fresh run, delete all left-overs from previous test
  expect_true(0 == unlink(c(
    "../../output/C_TESTTHAT-SSP2EU-Base-rem-1",
    "../../output/C_TESTTHAT-SSP2EU-Base-rem-2",
    "../../output/C_TESTTHAT-SSP2EU-Base-2.pdf",
    "../../output/C_TESTTHAT-SSP2EU-Base.mif",
    "../../output/C_TESTTHAT-SSP2EU-NDC-rem-1",
    "../../output/C_TESTTHAT-SSP2EU-NDC-rem-2",
    "../../output/C_TESTTHAT-SSP2EU-NDC-2.pdf",
    "../../output/C_TESTTHAT-SSP2EU-NDC.mif",
    "../../C_TESTTHAT-SSP2EU-Base-rem-1.RData",
    "../../C_TESTTHAT-SSP2EU-Base-rem-2.RData",
    "../../C_TESTTHAT-SSP2EU-NDC-rem-1.RData",
    "../../C_TESTTHAT-SSP2EU-NDC-rem-2.RData",
    "../../../magpie/output/C_TESTTHAT-SSP2EU-Base-mag-1",
    "../../../magpie/output/C_TESTTHAT-SSP2EU-NDC-mag-1"
    ),
    recursive = TRUE)
  )
  output <- localSystem2("Rscript", c("start_bundle_coupled.R", "config/tests/scenario_config_coupled_shortCascade.csv"),
                         env = "R_PROFILE_USER=.snapshot.Rprofile")
  printIfFailed(output)
  expectSuccessStatus(output)
})

test_that("(partially) completed coupled runs work", {
  skipIfFast()
  skipIfPreviousFailed()
  # do not delete anything to simulate re-running already completed run
  output <- localSystem2("Rscript", c("start_bundle_coupled.R", "config/tests/scenario_config_coupled_shortCascade.csv"),
                         env = "R_PROFILE_USER=.snapshot.Rprofile")
  printIfFailed(output)
  expectSuccessStatus(output)

  # delete a single late REMIND run to simulate re-starting aborted run
  expect_true(0 == unlink(c(
    "../../output/C_TESTTHAT-SSP2EU-NDC-rem-2",
    "../../output/C_TESTTHAT-SSP2EU-NDC-2.pdf",
    "../../output/C_TESTTHAT-SSP2EU-NDC.mif"
    ),
    recursive = TRUE)
  )
  output <- localSystem2("Rscript", c("start_bundle_coupled.R", "config/tests/scenario_config_coupled_shortCascade.csv"),
                         env = "R_PROFILE_USER=.snapshot.Rprofile")
  printIfFailed(output)
  expectSuccessStatus(output)

  # delete a late REMIND and MAgPIE run to simulate re-starting aborted run
  # which needs to start with MAgPIE
  expect_true(0 == unlink(c(
    "../../output/C_TESTTHAT-SSP2EU-NDC-rem-2",
    "../../output/C_TESTTHAT-SSP2EU-NDC-2.pdf",
    "../../output/C_TESTTHAT-SSP2EU-NDC.mif",
    "../../../magpie/output/C_TESTTHAT-SSP2EU-NDC-mag-1"
    ),
    recursive = TRUE)
  )
  output <- localSystem2("Rscript", c("start_bundle_coupled.R", "config/tests/scenario_config_coupled_shortCascade.csv"),
                         env = "R_PROFILE_USER=.snapshot.Rprofile")
  printIfFailed(output)
  expectSuccessStatus(output)
})
