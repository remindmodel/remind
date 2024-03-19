# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
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
#' @param gdxName Name of the REMIND GDX file. Defaults to "fulldata.gdx"

library(madrat)
library(remind2)
library(quitte)
library(piamInterfaces)
library(lucode2)
library(yaml)
library(tidyverse)
library(readr)
library(stringr)

############################# BASIC CONFIGURATION #############################

gdxName <- "fulldata.gdx"             # name of the gdx
cfgName <- "cfg.txt"                  # cfg file for getting file paths

if (!exists("source_include")) {
  # Define arguments that can be read from command line
  outputdir <- "."
  readArgs("outputdir", "gdxName", "gdx_ref_name", "gdx_refpolicycost_name")
}

cfgPath               <- file.path(outputdir, cfgName)
logFile               <- file.path(outputdir, "log_climate.txt") # specific log for python steps
scenario              <- getScenNames(outputdir)
remindReportingFile   <- file.path(outputdir, paste0("REMIND_generic_", scenario, ".mif"))
climateAssessmentEmi  <- normalizePath(file.path(outputdir, paste0("ar6_climate_assessment_", scenario, ".csv")),
                                       mustWork = FALSE)
climateAssessmentYaml <- file.path(system.file(package = "piamInterfaces"),
                                   "iiasaTemplates", "climate_assessment_variables.yaml")

############################# PREPARING EMISSIONS INPUT #############################

logmsg <- paste0(
  date(), " =================== CONFIGURATION STARTED ==================================\n",
  "  outputdir = '",             outputdir,              "' exists? ", file.exists(outputdir), "\n",
  "  cfgPath = '",               cfgPath,                "' exists? ", file.exists(cfgPath), "\n",
  "  logFile = '",               logFile,                "' exists? ", file.exists(logFile), "\n",
  "  scenario = '",              scenario, "'\n",
  "  remindReportingFile = '",   remindReportingFile,   "' exists? ", file.exists(remindReportingFile), "\n",
  "  climateAssessmentYaml = '", climateAssessmentYaml, "' exists? ", file.exists(climateAssessmentYaml), "\n",
  "  climateAssessmentEmi = '",  climateAssessmentEmi,  "' exists? ", file.exists(climateAssessmentEmi), "\n",
  date(), " =================== EXTRACT REMIND emission data ===========================\n",
  "  MAGICC7_AR6.R: Extracting REMIND emission data\n"
)
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = TRUE)

climateAssessmentInputData <- as.quitte(remindReportingFile) %>%
  # Consider only the global region
  filter(region %in% c("GLO", "World")) %>%
  # Extract only the variables needed for climate-assessment. These are provided from the iiasaTemplates in the
  # piamInterfaces package. See also:
  # https://github.com/pik-piam/piamInterfaces/blob/master/inst/iiasaTemplates/climate_assessment_variables.yaml
  generateIIASASubmission(
    mapping = "AR6",
    outputFilename = NULL,
    iiasatemplate = climateAssessmentYaml,
    logFile = logFile
  ) %>%
  mutate(region = factor("World")) %>%
  # Rename the columns using str_to_title which capitalizes the first letter of each word
  rename_with(str_to_title) %>%
  # Transforms the yearly values for each variable from a long to a wide format. The resulting data frame then has
  # one column for each year and one row for each variable
  pivot_wider(names_from = "Period", values_from = "Value") %>%
  write_csv(climateAssessmentEmi, quote = "none")

logmsg <- paste0(
  date(), "  MAGICC7_AR6.R: Wrote REMIND emission data to '", climateAssessmentEmi, "' for climate-assessment\n"
)
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = TRUE)

############################# PYTHON/MAGICC SETUP #############################

# Read the cfg to get the location of MAGICC-related files
cfg <- read_yaml(cfgPath)

if (is.null(cfg$climate_assessment_root)) cfg$climate_assessment_root <- "/p/projects/rd3mod/python/climate-assessment/src/"
if (is.null(cfg$climate_assessment_files_dir)) cfg$climate_assessment_files_dir <- "/p/projects/rd3mod/climate-assessment-files/"
if (is.null(cfg$cfg$climate_assessment_magicc_bin)) cfg$climate_assessment_magicc_bin <- "/p/projects/rd3mod/climate-assessment-files/magicc-v7.5.3/bin/magicc"

# All climate-assessment files will be written to this folder
climateAssessmentFolder <- normalizePath(file.path(outputdir, "climate-assessment-data"))
dir.create(climateAssessmentFolder, showWarnings = FALSE)

# The base name, that climate-assessment uses to derive it's output names
baseFileName <- sub("\\.csv$", "", basename(climateAssessmentEmi))

# These files are supposed to be all inside cfg$climate_assessment_files_dir in a certain structure
probabilisticFile <- normalizePath(file.path(
  cfg$climate_assessment_files_dir,
  "parsets", "0fd0f62-derived-metrics-id-f023edb-drawnset.json"
))
infillingDatabaseFile <- normalizePath(file.path(
  cfg$climate_assessment_files_dir,
  "1652361598937-ar6_emissions_vetted_infillerdatabase_10.5281-zenodo.6390768.csv"
))

# Extract the location of the climate-assessment scripts and the MAGICC binary from cfg.txt
scriptsFolder       <- normalizePath(file.path(cfg$climate_assessment_root, "scripts"))
magiccBinFile       <- normalizePath(file.path(cfg$climate_assessment_magicc_bin))
magiccWorkersFolder <- file.path(normalizePath(climateAssessmentFolder), "workers")

# Read parameter sets file to ascertain how many parsets there are
allparsets <- read_yaml(probabilisticFile)
nparsets <- length(allparsets$configurations)

logmsg <- paste0(date(), " =================== SET UP climate-assessment scripts environment ===================\n")
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = TRUE)

# Create working folder for climate-assessment files
dir.create(magiccWorkersFolder, recursive = TRUE, showWarnings = FALSE)

# Set relevant environment variables and create a MAGICC worker directory
Sys.setenv(MAGICC_EXECUTABLE_7 = magiccBinFile)
Sys.setenv(MAGICC_WORKER_ROOT_DIR = magiccWorkersFolder) # Has to be an absolute path
Sys.setenv(MAGICC_WORKER_NUMBER = 1) # TODO: Get this from slurm or nproc

# Specify the commands to (de-)activate the venv & run the harmonization/infilling/model scripts
# TODO: This makes assumptions about the users climate-assessment installation. There are a couple of options:
# A) Remove entirely and assume that the user has set up their environment correctly
# B) Make this more flexible by explictly setting them in default.cfg
#activate_venv_cmd <- paste("source", normalizePath(file.path(cfg$climate_assessment_root, "..", "venv", "bin", "activate")))
#deactivate_venv_cmd <- "deactivate"

runHarmoniseAndInfillCmd <- paste(
  "python", file.path(scriptsFolder, "run_harm_inf.py"),
  climateAssessmentEmi,
  climateAssessmentFolder,
  "--no-inputcheck",
  "--infilling-database", infillingDatabaseFile
)

runClimateEmulatorCmd <- paste(
  "python", file.path(scriptsFolder, "run_clim.py"),
  normalizePath(file.path(climateAssessmentFolder, paste0(baseFileName, "_harmonized_infilled.csv"))),
  climateAssessmentFolder,
  "--num-cfgs", nparsets,
  "--scenario-batch-size", 1,
  "--probabilistic-file", probabilisticFile
)

logmsg <- paste0(
  "  climateAssessmentFolder = '", climateAssessmentFolder, "' exists? ", dir.exists(climateAssessmentFolder), "\n",
  "  baseFileName = '",            baseFileName, "'\n",
  "  probabilisticFile = '",       probabilisticFile,       "' exists? ", file.exists(probabilisticFile), "\n",
  "  infillingDatabaseFile = '",   infillingDatabaseFile,   "' exists? ", file.exists(infillingDatabaseFile), "\n",
  "  scriptsFolder = '",           scriptsFolder,           "' exists? ", dir.exists(scriptsFolder), "\n",
  "  magiccBinFile = '",           magiccBinFile,           "' exists? ", file.exists(magiccBinFile), "\n",
  "  magiccWorkersFolder = '",     magiccWorkersFolder,     "' exists? ", dir.exists(magiccWorkersFolder), "\n\n",
  "  ENVIRONMENT VARIABLES:\n",
  "  MAGICC_EXECUTABLE_7    = ", Sys.getenv("MAGICC_EXECUTABLE_7") ,"\n",
  "  MAGICC_WORKER_ROOT_DIR = ", Sys.getenv("MAGICC_WORKER_ROOT_DIR") ,"\n",
  "  MAGICC_WORKER_NUMBER   = ", Sys.getenv("MAGICC_WORKER_NUMBER") ,"\n",
  date(), " =================== RUN climate-assessment infilling & harmonization ===================\n",
  runHarmoniseAndInfillCmd, "'\n"
)
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = TRUE)

############################# HARMONIZATION/INFILLING #############################

system(runHarmoniseAndInfillCmd)

logmsg <- paste0(date(), "  Done with harmonization & infilling\n")
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = TRUE)

############################# RUNNING MODEL #############################

logmsg <- paste0(
  date(), "  Found ", nparsets, " nparsets, start climate-assessment climate emulator step\n", 
  runHarmoniseAndInfillCmd, "\n",
  date(), " =================== RUN climate-assessment model ============================\n",
  runClimateEmulatorCmd, "'\n"
)
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = TRUE)

system(runClimateEmulatorCmd)

############################# POSTPROCESS CLIMATE OUTPUT #############################
climateAssessmentOutput <- file.path(
  climateAssessmentFolder,
  paste0(baseFileName, "_harmonized_infilled_IAMC_climateassessment.xlsx")
)

logmsg <- paste0(
  date(), "  climate-assessment climate emulator finished\n",
  date(), " =================== POSTPROCESS climate-assessment output ==================\n",
  "  climateAssessmentOutput = '", climateAssessmentOutput, "'\n"
)
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = TRUE)

############################# APPEND TO REMIND MIF #############################
# Filter only periods used in REMIND, so that it doesn't expand the original mif
usePeriods <- as.numeric(grep("[0-9]+", quitte::read_mif_header(remindReportingFile)$header, value = TRUE))

climateAssessmentData <- read.quitte(climateAssessmentOutput) %>%
  filter(period %in% usePeriods) %>%
  interpolate_missing_periods(usePeriods, expand.values = FALSE) %>%
  mutate(variable = gsub("|MAGICCv7.5.3", "", .data$variable, fixed = TRUE)) %>%
  mutate(variable = gsub("AR6 climate diagnostics|", "MAGICC7 AR6|", .data$variable, fixed = TRUE))

as.quitte(remindReportingFile) %>%
  # remove data from old MAGICC7 runs to avoid duplicated
  filter(! grepl("AR6 climate diagnostics.*MAGICC7", .data$variable), ! grepl("^MAGICC7 AR6", .data$variable)) %>%
  rbind(climateAssessmentData) %>%
  write.mif(remindReportingFile)

deletePlus(remindReportingFile, writemif = TRUE)

logmsg <- paste0(
  date(), " postprocessing done! Results appended to REMIND mif '", remindReportingFile, "'\n",
  "MAGICC7_AR6.R finished\n"
)
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = TRUE)
