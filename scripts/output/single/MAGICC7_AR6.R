# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

#' @title AR6 climate assessment
#' @description Assessment of new emissions pathways consistent with the climate variable data from the working group
#' III contribution to the IPCC Sixth Assessment (AR6) report. The script uses REMIND emissions data to perform
#' harmonization and infilling based on the IIASA [climate-assessment](https://climate-assessment.readthedocs.io)
#' package. The harmonized and infilled emissions are then used as input to the
#' [MAGICC7 simple climate model](https://magicc.org/). Results are postprocessed and appended to the REMIND model
#' intercomparison file (MIF).
#'
#' @author Gabriel Abrahao, Oliver Richters, Tonn Rüter
#'
#' @param outputdir Directory where REMIND MIF file is located. Output files generated in the process will be written
#' to a subfolder "climate-assessment-data" in this directory. Defaults to "."

library(dplyr)
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

if (!exists("source_include")) {
  # Define arguments that can be read from command line
  outputdir <- "."
  readArgs("outputdir", "gdxName", "gdx_ref_name", "gdx_refpolicycost_name")
}

runTimes <- c()
runTimes <- c(runTimes, "set_up_assessment start" = Sys.time())
# Normalize the output directory path, removing trailing slashes
outputdir <- sub("/+$", "", normalizePath(outputdir, mustWork = TRUE))
# cfg is a list containing all relevant paths and settings for the climate assessment
cfg <- climateAssessmentConfig(outputdir, "report")
# Keep track of runtimes of different parts of the script
cat(date(), "MAGICC7_AR6.R:", reportClimateAssessmentConfig(cfg), file = cfg$logFile, append = TRUE)

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
  "python", file.path(cfg$scriptsDir, "run_clim.py"), cfg$harmInfEmissionsFile, cfg$climateDir,
  "--num-cfgs", cfg$nSets,
  "--scenario-batch-size", 1,
  "--probabilistic-file", cfg$probabilisticFile
)

runTimes <- c(runTimes, "set_up_assessment end" = Sys.time())

#################### PREPARING EMISSIONS INPUT ####################################################

remindReportingFile <- normalizePath(
  file.path(outputdir, paste0("REMIND_generic_", cfg$scenario, ".mif")),
  mustWork = TRUE
)
cat(date(), "MAGICC7_AR6.R: Using ", remindReportingFile, file = cfg$logFile, append = TRUE)
runTimes <- c(runTimes, "preprocessing start" = Sys.time())

climateAssessmentInputData <- as.quitte(remindReportingFile) %>%
  emissionDataForClimateAssessment(cfg$scenario, logFile = cfg$logFile) %>%
  write_csv(cfg$remindEmissionsFile, quote = "none")

runTimes <- c(runTimes, "preprocessing end" = Sys.time())
cat(
  date(), "MAGICC7_AR6.R: Extracted REMIND emission data to", cfg$remindEmissionsFile, "for climate-assessment\n",
  file = cfg$logFile, append = TRUE
)

#################### HARMONIZATION/INFILLING ######################################################

runTimes <- c(runTimes, "harmonization_infilling start" = Sys.time())
condaRun(runHarmoniseAndInfillCmd, cfg$condaEnv, env = magiccEnv, init = magiccInit, log = cfg$logFile, verbose = 1)
runTimes <- c(runTimes, "harmonization_infilling end" = Sys.time())
cat(date(), "MAGICC7_AR6.R: Done with harmonization & infilling\n", file = cfg$logFile, append = TRUE)

#################### RUNNING MODEL ################################################################

runTimes <- c(runTimes, "emulation start" = Sys.time())
condaRun(runClimateEmulatorCmd, cfg$condaEnv, env = magiccEnv, init = magiccInit, log = cfg$logFile, verbose = 1)
runTimes <- c(runTimes, "emulation end" = Sys.time())
cat(date(), "MAGICC7_AR6.R: Done with climate assessment\n", file = cfg$logFile, append = TRUE)

#################### POSTPROCESS CLIMATE OUTPUT, APPEND TO REMIND MIF #############################

if (!file.exists(cfg$climateAssessmentFile)) {
  stop(date(), "MAGICC7_AR6.R: Climate assessment output file not found")
}
cat(date(), "MAGICC7_AR6.R: Produced", cfg$climateAssessmentFile, "\n", file = cfg$logFile, append = TRUE)

runTimes <- c(runTimes, "postprocessing start" = Sys.time())
# Filter only periods used in REMIND, so that it doesn't expand the original mif
periods <- as.numeric(grep("[0-9]+", quitte::read_mif_header(remindReportingFile)$header, value = TRUE))
climateAssessmentData <- read.quitte(cfg$climateAssessmentFile) %>%
  cleanUpClimateAssessment(periods = periods) %>%
  appendClimateAssessmentToMif(remindReportingFile)
piamutils::deletePlus(remindReportingFile, writemif = TRUE)

runTimes <- c(runTimes, "postprocessing end" = Sys.time())
cat(
  date(), " MAGICC7_AR6.R: Done postprocessing! Results appended to REMIND mif '", remindReportingFile, "'\n",
  sep = "", file = cfg$logFile, append = TRUE
)

#################### CLEAN UP WORKERS FOLDER ######################################################

# openscm_runner does not remnove up temp dirs. Do this manually since we keep running into file ownership issues
if (dir.exists(cfg$workersDir)) {
  # Check if directory is empty
  if (length(list.files(cfg$workersDir)) == 0) {
    # Remove directory. Option recursive must be TRUE for some reason, otherwise unlink won't do its job
    unlink(cfg$workersDir, recursive = TRUE)
  }
}
cat(date(), "MAGICC7_AR6.R: Removed workers folder\n", file = cfg$logFile, append = TRUE)

#################### RUNTIME REPORT ###############################################################

cat(
  date(), " MAGICC7_AR6.R: Run times in secs:\n", runTimeReport(runTimes, prefix = "  "), "\n",
  sep = "", file = cfg$logFile, append = TRUE
)
cat(date(), "MAGICC7_AR6.R: Done!\n", file = cfg$logFile, append = TRUE)
