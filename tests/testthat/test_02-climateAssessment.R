# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
test_that("climate assessment Python environment provides required tools", {
  skipIfPreviousFailed()
  cfg <- gms::readDefaultConfig("../..")
  # smoke test for scripts/output/single/MAGICC7_AR6.R, which runs the
  # ca-harmonize-infill and ca-run-climate console scripts from the Python environment
  # specified by cfg$pythonPath using the binary in cfg$climate_assessment_magicc_bin.

  # skip outside the cluster where required tools don't exist
  skip_if_not(dir.exists(cfg$pythonPath),
              paste("No Python environment for climate assessment at cfg$pythonPath:", cfg$pythonPath))
  skip_if_not(file.exists(cfg$climate_assessment_magicc_bin),
              paste("No MAGICC binary at cfg$climate_assessment_magicc_bin:", cfg$climate_assessment_magicc_bin))
  entrypoints <- c("ca-harmonize-infill", "ca-run-climate")
  binaries <- file.path(cfg$pythonPath, "bin", entrypoints)
  for (binary in binaries) {
    # --help must work, this imports climate_assessment and its dependencies
    status <- as.integer(system2(binary, "--help", stdout = FALSE, stderr = FALSE))
    expect_identical(status, 0L, info = paste0(binary, " --help failed"))
  }
})
