# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
# !/bin/bash
library(dplyr)
require(gdxrrw) # Needs an environmental variable to be set, see below
library(lucode2)
library(magrittr)
library(piamInterfaces)
library(piamenv)
library(piamutils)
library(quitte)
library(readr)
library(remind2)
library(remindClimateAssessment)
library(stringr)
library(tidyverse)


#################### BASIC CONFIGURATION ##########################################################

runTimes <- c()
runTimes <- c(runTimes, "set_up_assessment start" = Sys.time())

# This script is meant to run the full IIASA climate assessment using a single parameter set,
# meant to be used between REMIND iterations

outputDir <- getwd()
# cfg is a list containing all relevant paths and settings for the climate assessment
cfg <- climateAssessmentConfig(outputDir, "iteration")
# Keep track of runtimes of different parts of the script
cat(date(), "climateAssessmentInterimRun.R:", reportClimateAssessmentConfig(cfg), file = cfg$logFile, append = TRUE)

#################### PYTHON/MAGICC SETUP ##########################################################

dir.create(cfg$climateDir, showWarnings = FALSE)
dir.create(cfg$workersDir, showWarnings = FALSE)

magiccEnv <- c(
  "MAGICC_EXECUTABLE_7"    = cfg$magiccBin,
  "MAGICC_WORKER_ROOT_DIR" = cfg$workersDir,
  "MAGICC_WORKER_NUMBER"   = 1
)

magiccInit <- condaInit(how = "pik-cluster", log = cfg$logFile, verbose = 1)

runHarmoniseAndInfillCmd <- paste(
  "python", file.path(cfg$scriptsDir, "run_harm_inf.py"), cfg$remindEmissionsFile, cfg$climateDir,
  "--infilling-database", cfg$infillingDatabase
)

runClimateEmulatorCmd <- paste(
  "python", file.path(system.file(package = "remindClimateAssessment"), "runOpenSCM.py"), cfg$harmInfEmissionsFile,
  "--climatetempdir", cfg$climateDir,
  # Note: Option --year-filter-last requires https://github.com/gabriel-abrahao/climate-assessment/tree/yearfilter
  "--endyear", 2250,
  "--num-cfgs", cfg$nSets,
  "--scenario-batch-size", 1,
  "--probabilistic-file", cfg$probabilisticFile
)

runTimes <- c(runTimes, "set_up_assessment end" = Sys.time())

#################### PREPARING EMISSIONS INPUT ####################################################

gdxFile <- normalizePath(file.path(outputDir, "fulldata_postsolve.gdx"), mustWork = TRUE)

cat(date(), "climateAssessmentInterimRun.R: Using", gdxFile, "\n", file = cfg$logFile, append = TRUE)
runTimes <- c(runTimes, "preprocessing start" = Sys.time())

climateAssessmentInputData <- reportEmiForClimateAssessment(gdxFile) %>%
  as.quitte() %>%
  emissionDataForClimateAssessment(cfg$scenario, mapping = "climateassessment", logFile = cfg$logFile) %>%
  write_csv(cfg$remindEmissionsFile, quote = "none")

runTimes <- c(runTimes, "preprocessing end" = Sys.time())
cat(
  date(), "climateAssessmentInterimRun.R: Emission data for climate-assessment", cfg$remindEmissionsFile, "\n",
  file = cfg$logFile, append = TRUE
)

#################### HARMONIZATION/INFILLING ######################################################

runTimes <- c(runTimes, "harmonization_infilling start" = Sys.time())
condaRun(runHarmoniseAndInfillCmd, cfg$condaEnv, env = magiccEnv, init = magiccInit, log = cfg$logFile, verbose = 1)
runTimes <- c(runTimes, "harmonization_infilling end" = Sys.time())
cat(date(), "climateAssessmentInterimRun.R: Done with harmonization & infilling\n", file = cfg$logFile, append = TRUE)

#################### RUNNING MODEL ################################################################

runTimes <- c(runTimes, "emulation start" = Sys.time())
condaRun(runClimateEmulatorCmd, cfg$condaEnv, env = magiccEnv, init = magiccInit, log = cfg$logFile, verbose = 1)
runTimes <- c(runTimes, "emulation end" = Sys.time())
cat(date(), "climateAssessmentInterimRun.R: Done with climate assessment\n", file = cfg$logFile, append = TRUE)

#################### POSTPROCESS CLIMATE OUTPUT ###################################################

if (!file.exists(cfg$climateAssessmentFile)) {
  stop(date(), "climateAssessmentInterimRun.R: Climate assessment output file not found")
}
cat(
  date(), "climateAssessmentInterimRun.R: Produced", cfg$climateAssessmentFile, "\n",
  file = cfg$logFile, append = TRUE
)

runTimes <- c(runTimes, "postprocessing start" = Sys.time())

gdxExportCfg <- file.path(system.file(package = "remindClimateAssessment"), "default.yaml")
# The variable/file association determines which variables are extracted from the MAGICC7 output file
# and dumped into which GDX file(s)
associateVariablesAndFiles <- exportConfFromYaml(gdxExportCfg)
thesePlease <- unique(associateVariablesAndFiles$magicc7Variable)
climateAssessmentData <- read.quitte(cfg$climateAssessmentFile) %>%
  filter(variable %in% thesePlease) %>%
  pivot_wider(names_from = "period", values_from = "value") %>%
  mutate(variable = vapply(.data$variable, renameVariableMagicc7ToRemind, USE.NAMES = FALSE, FUN.VALUE = character(1)))
runTimes <- c(runTimes, "postprocessing end" = Sys.time())

# Loop through each file name given in associateVariablesAndFiles and write the associated variables to GDX files
# Note: This arrangement is capable of writing multiple variables to the same GDX file
runTimes <- c(runTimes, "write_gdx start" = Sys.time())

for (currentFn in unique(unlist(associateVariablesAndFiles$fileName))) {
  cat(date(), "climateAssessmentInterimRun.R: Wrote", currentFn, "\n", file = cfg$logFile, append = TRUE)
  dumpToGdx(climateAssessmentData, currentFn, associateVariablesAndFiles)
}

runTimes <- c(runTimes, "write_gdx end" = Sys.time())

# Archive the data: Get the list of xlsx and csv files in climateTempDir and the relevant gdx-es in outputDir
if (cfg$isArchived) {
  runTimes <- c(runTimes, "archive_data start" = Sys.time())
  dir.create(cfg$archiveDir, showWarnings = FALSE)
  extras <- normalizePath(file.path(outputDir, paste0(associateVariablesAndFiles$fileName, ".gdx")), mustWork = TRUE)
  # Use the run mode as suffix to the tar archive file name, hence the paste0("_", cfg$mode)
  tarfile <- archiveClimateAssessmentData(cfg$climateDir, cfg$archiveDir, paste0("_", cfg$mode), extraFiles = extras)
  cat(
    date(), "climateAssessmentInterimRun.R: Archived climate assessment data to", tarfile, "\n",
    file = cfg$logFile, append = TRUE
  )
  runTimes <- c(runTimes, "archive_data end" = Sys.time())
}

#################### CLEAN UP WORKERS FOLDER ######################################################

# openscm_runner does not remnove up temp dirs. Do this manually since we keep running into file ownership issues
if (dir.exists(cfg$workersDir)) {
  # Check if directory is empty
  if (length(list.files(cfg$workersDir)) == 0) {
    # Remove directory. Option recursive must be TRUE for some reason, otherwise unlink won't do its job
    unlink(cfg$workersDir, recursive = TRUE)
  }
}
cat(date(), "climateAssessmentInterimRun.R: Removed workers folder\n", file = cfg$logFile, append = TRUE)

#################### RUNTIME REPORT ###############################################################

cat(
  date(), " climateAssessmentInterimRun.R: Run times in secs:\n", runTimeReport(runTimes, prefix = "  "), "\n",
  sep = "", file = cfg$logFile, append = TRUE
)
cat(date(), "climateAssessmentInterimRun.R: Done!\n", file = cfg$logFile, append = TRUE)