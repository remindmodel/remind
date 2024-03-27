# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
#!/bin/bash
require(remind2)
require(quitte)
require(piamInterfaces)
require(yaml)
require(tidyverse)
# require(madrat)
require(lucode2)

# This script is meant to run the full IIASA climate assessment using a single parameter set,
# meant to be used between REMIND iterations

outputDir <- getwd()

# Way to get the number of iterations?
#as.numeric(readGDX(gdx = "input.gdx", "o_iterationNumber", format = "simplest"))

logFile <- file.path(outputDir, paste0("log_climate_", format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), ".txt"))
if (!file.exists(logFile)) {
    file.create(logFile)
    createdLogFile <- TRUE
} else {
    createdLogFile <- FALSE
}

climateTempDir <- file.path(outputDir, "climate-assessment-data")
if (!exists(climateTempDir)) {
    dir.create(climateTempDir, showWarnings = FALSE)
    createdClimateTempDir <- TRUE
} else {
    createdClimateTempDir <- FALSE
}

gdxPath <- file.path(outputDir, "fulldata_prepostsolve.gdx")
cfgPath <- file.path(outputDir, "cfg.txt")

logMsg <- paste0(
    date(), " climate_assessment_run.R:\n",
    "outputDir              '", outputDir, "'\n",
    "Using gdxPath          '", gdxPath, "'\n",
    "Using config           '", cfgPath, "'\n",
    if (createdLogFile) "Created logfile        '" else "Append to logFile      '", logFile, "'\n",
    if (createdClimateTempDir) "Created climateTempDir '" else "Using climateTempDir   '", climateTempDir, "'\n",
    date(), " climate_assessment_run.R: Start Postprocessing GDX file\n"
)
cat(logMsg)
capture.output(cat(logMsg), file = logFile, append = TRUE)

#
# POSTPROCESSING GDX FILE
#

# Get the scenario name
scenarioName <- getScenNames(outputDir)

# Set up climate-assessment related configuration and output files
climateAssessmentYaml <- file.path(
    system.file(package = "piamInterfaces"), "iiasaTemplates", "climate_assessment_variables.yaml")
climateAssessmentEmi <- file.path(climateTempDir, paste0("ar6_climate_assessment_", scenarioName, ".csv"))
if (!file.exists(climateAssessmentEmi)) {
    file.create(climateAssessmentEmi)
    createdOutputCsv <- TRUE
} else {
    createdOutputCsv <- FALSE
}

logMsg <- paste0(
    date(), " climate_assessment_prepare.R: \n",
    "Using climateAssessmentYaml '", climateAssessmentYaml, "'\n",
    "Start reportEmi\n"
)
cat(logMsg)
capture.output(cat(logMsg), file = logFile, append = TRUE)

#
# Run emissions report here
#
timeStartPreprocessing <- Sys.time()
emiReport <- reportEmi(gdxPath)

logMsg <- paste0(
    date(), " climate_assessment_prepare.R: Done reportEmi, start to wrangle emissions report into shape\n"
)
cat(logMsg)
capture.output(cat(logMsg), file = logFile, append = TRUE)

#
# Since the script is called in between runs, we need convert the emissions report each time
#
climateAssessmentInputData <- emiReport %>%
    as.quitte() %>%
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
    mutate(region = factor("World"), scenario = factor(scenarioName)) %>%
    # Rename the columns using str_to_title which capitalizes the first letter of each word
    rename_with(str_to_title) %>%
    # Transforms the yearly values for each variable from a long to a wide format. The resulting data frame then has
    # one column for each year and one row for each variable
    pivot_wider(names_from = "Period", values_from = "Value") %>%
    write_csv(climateAssessmentEmi, quote = "none")

timeStopPreprocessing <- Sys.time()
logMsg <- paste0(
    date(), " climate_assessment_prepare.R: Done data wrangling\n",
    "Runtime preprocessing: ", timeStopPreprocessing - timeStartPreprocessing, "s \n",
    date(), " climate_assessment_prepare.R: ", if (createdOutputCsv) "Created" else "Replaced", 
    " climateAssessmentEmi '", climateAssessmentEmi, "'\n"
)
cat(logMsg)
capture.output(cat(logMsg), file = logFile, append = TRUE)

#
# RUN CLIMATE ASSESSMENT
#
cfg <- read_yaml(cfgPath)
# Set default values for the climate assessment config data in case they are not available for backward compatibility
if (is.null(cfg$climate_assessment_root)) cfg$climate_assessment_root <- "/p/projects/rd3mod/python/climate-assessment/src/"
if (is.null(cfg$climate_assessment_files_dir)) cfg$climate_assessment_files_dir <- "/p/projects/rd3mod/climate-assessment-files/"
if (is.null(cfg$cfg$climate_assessment_magicc_bin)) cfg$climate_assessment_magicc_bin <- "/p/projects/rd3mod/climate-assessment-files/magicc-v7.5.3/bin/magicc"

# The base name, that climate-assessment uses to derive it's output names
baseFn <- sub("\\.csv$", "", basename(climateAssessmentEmi))

# These files are supposed to be all inside cfg$climate_assessment_files_dir in a certain structure
probabilisticFile <- normalizePath(file.path(
    cfg$climate_assessment_files_dir,
    "parsets", "RCP20_50.json"
))
infillingDatabaseFile <- normalizePath(file.path(
    cfg$climate_assessment_files_dir,
    "1652361598937-ar6_emissions_vetted_infillerdatabase_10.5281-zenodo.6390768.csv"
))

# Extract the location of the climate-assessment scripts and the MAGICC binary from cfg.txt
scriptsDir <- normalizePath(file.path(cfg$climate_assessment_root, "scripts"))
magiccBinFile <- normalizePath(file.path(cfg$climate_assessment_magicc_bin))
magiccWorkersDir <- file.path(normalizePath(climateTempDir), "workers")

# Read parameter sets file to ascertain how many parsets there are
allparsets <- read_yaml(probabilisticFile)
nparsets <- length(allparsets$configurations)

logmsg <- paste0(date(), " =================== SET UP climate-assessment scripts environment ===================\n")
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = TRUE)

# Create working folder for climate-assessment files
dir.create(magiccWorkersDir, recursive = TRUE, showWarnings = FALSE)

#
# SET UP MAGICC ENVIRONMENT VARIABLES
#

# Character vector of all required MAGICC7 environment variables
magiccEnvs <- c(
    "MAGICC_EXECUTABLE_7"    = magiccBinFile,    # Specifies the path to the MAGICC executable
    "MAGICC_WORKER_ROOT_DIR" = "", # Directory of magicc workers
    "MAGICC_WORKER_NUMBER"   = 1                 # TODO: Get this from slurm or nproc
)

# Check if all necessary environment variables are set
alreadySet <- lapply(Sys.getenv(names(magiccEnvs)), nchar) > 0
# Only set those environment variables that are not already set
if (any(!alreadySet)) do.call(Sys.setenv, as.list(magiccEnvs[!alreadySet]))

#
# BUILD climate-assessment RUN COMMANDS
#
runHarmoniseAndInfillCmd <- paste(
    "python", file.path(scriptsDir, "run_harm_inf.py"),
    climateAssessmentEmi,
    climateTempDir,
    "--no-inputcheck",
    "--infilling-database", infillingDatabaseFile
)

runClimateEmulatorCmd <- paste(
    "python", file.path(scriptsDir, "run_clim.py"),
    normalizePath(file.path(climateTempDir, paste0(baseFn, "_harmonized_infilled.csv"))),
    climateTempDir,
    "--num-cfgs", nparsets,
    "--scenario-batch-size", 1,
    "--probabilistic-file", probabilisticFile
)

logmsg <- paste0(
    date(), "  CLIMATE-ASSESSMENT ENVIRONMENT:\n",
    "  climateTempDir        = '", climateTempDir, "' exists? ", dir.exists(climateTempDir), "\n",
    "  baseFn                = '", baseFn, "'\n",
    "  probabilisticFile     = '", probabilisticFile, "' exists? ", file.exists(probabilisticFile), "\n",
    "  infillingDatabaseFile = '", infillingDatabaseFile, "' exists? ", file.exists(infillingDatabaseFile), "\n",
    "  scriptsDir            = '", scriptsDir, "' exists? ", dir.exists(scriptsDir), "\n",
    "  magiccBinFile         = '", magiccBinFile, "' exists? ", file.exists(magiccBinFile), "\n",
    "  magiccWorkersDir      = '", magiccWorkersDir, "' exists? ", dir.exists(magiccWorkersDir), "\n\n",
    "  ENVIRONMENT VARIABLES:\n",
    "  MAGICC_EXECUTABLE_7    = ", Sys.getenv("MAGICC_EXECUTABLE_7"), "\n",
    "  MAGICC_WORKER_ROOT_DIR = ", Sys.getenv("MAGICC_WORKER_ROOT_DIR"), "\n",
    "  MAGICC_WORKER_NUMBER   = ", Sys.getenv("MAGICC_WORKER_NUMBER"), "\n",
    date(), " =================== RUN climate-assessment infilling & harmonization ===================\n",
    runHarmoniseAndInfillCmd, "'\n"
)
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = TRUE)

############################# HARMONIZATION/INFILLING #############################

timeStartHarmInf <- Sys.time()
system(runHarmoniseAndInfillCmd)
timeStopHarmInf <- Sys.time()

logmsg <- paste0(date(), "  Done with harmonization & infilling in ", timeStopHarmInf - timeStartHarmInf, "s\n")
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

timeStartEmulation <- Sys.time()
system(runClimateEmulatorCmd)
timeStopEmulation <- Sys.time()

############################# POSTPROCESS CLIMATE OUTPUT #############################
climateAssessmentOutput <- file.path(
    climateTempDir,
    paste0(baseFn, "_harmonized_infilled_IAMC_climateassessment.xlsx")
)

logmsg <- paste0(
    date(), "  climate-assessment climate emulator finished in ", timeStopEmulation - timeStartEmulation, "s\n",
    date(), " =================== POSTPROCESS climate-assessment output ==================\n",
    "  climateAssessmentOutput = '", climateAssessmentOutput, "'\n"
)
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = TRUE)

# Replace with reading the raw CSV if PR43 of climate-assessment is accepted
# This `0000` file is suppposed to be an intermediate file, not final output
cmd <- paste0("Rscript climate_assessment_writegdxs.R ", climateAssessmentOutput)
# cmd <- paste0("Rscript climate_assessment_writegdxs.R ", climateTempDir, "/", baseFn, "_harmonized_infilled_IAMC_climateassessment0000.csv")
system(cmd)

logmsg <- paste0(date(), " Finished all\n")
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = T)


