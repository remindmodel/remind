# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
# !/bin/bash
require(remind2)
require(quitte)
require(piamInterfaces)
require(yaml)
require(tidyverse)
require(lucode2)
require(purrr)
require(gdxrrw) # Needs an environmental variable to be set, see below
require(R.utils)

timeStartSetUpScript <- Sys.time()
renameVariableMagicc7ToRemind <- function(varName) {
  varName <- gsub("|MAGICCv7.5.3", "", varName, fixed = TRUE)
  varName <- gsub("AR6 climate diagnostics|", "MAGICC7 AR6|", varName, fixed = TRUE)
  return(varName)
}

# This script is meant to run the full IIASA climate assessment using a single parameter set,
# meant to be used between REMIND iterations

outputDir <- getwd()
gdxPath <- file.path(outputDir, "fulldata_postsolve.gdx")
cfgPath <- file.path(outputDir, "cfg.txt")
cfg <- read_yaml(cfgPath)
archiveClimateAssessmentData <- cfg$climate_assessment_archive
timestamp <- format(timeStartSetUpScript, "%Y%m%d_%H%M%S")

logFile <- file.path(outputDir, paste0("log_climate.txt"))
if (!file.exists(logFile)) {
  file.create(logFile)
  createdLogFile <- TRUE
} else {
  createdLogFile <- FALSE
}

climateTempDir <- file.path(outputDir, "climate-assessment-data")
if (!dir.exists(climateTempDir)) {
  dir.create(climateTempDir, showWarnings = FALSE)
  createdClimateTempDir <- TRUE
} else {
  createdClimateTempDir <- FALSE
}
cat(climateTempDir)

# Create dir to archive the climate assessment data after script has finished
if (archiveClimateAssessmentData) {
  climateArchiveDir <- file.path(climateTempDir, "archive", paste0("iteration_", timestamp))
  if (!dir.exists(climateArchiveDir)) {
    dir.create(climateArchiveDir, recursive = TRUE, showWarnings = FALSE)
    createdClimateArchiveDir <- TRUE
  } else {
    createdClimateArchiveDi <- FALSE
  }
}

logMsg <- paste0(
  date(), " climate_assessment_run.R:\n",
  "outputDir              '", outputDir, "'\n",
  "Using gdxPath          '", gdxPath, "'\n",
  "Using config           '", cfgPath, "'\n",
  if (createdLogFile) "Created logfile        '" else "Append to logFile      '", logFile, "'\n",
  if (createdClimateTempDir) "Created climateTempDir '" else "Using climateTempDir   '", climateTempDir, "'\n",
  if (archiveClimateAssessmentData) paste0("Created climateArchiveDir '", climateArchiveDir, "'\n"),
  date(), " climate_assessment_run.R: Start Postprocessing GDX file\n"
)
capture.output(cat(logMsg), file = logFile, append = TRUE)

#
# POSTPROCESSING GDX FILE
#

# Get the scenario name
scenarioName <- getScenNames(outputDir)

# Set up climate-assessment related configuration and output files
climateAssessmentYaml <- file.path(
  system.file(package = "piamInterfaces"), "iiasaTemplates", "climate_assessment_variables.yaml"
)
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
capture.output(cat(logMsg), file = logFile, append = TRUE)
timeStopSetUpScript <- Sys.time()

#
# Run emissions report here
# Includes air pollutant emissions from reportEmiAirPol()
#
timeStartPreprocessing <- Sys.time()
emiReport <- reportEmiForClimateAssessment(gdxPath)

logMsg <- paste0(
  date(), " climate_assessment_prepare.R: Done reportEmi, start to wrangle emissions report into shape\n"
)
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
  date(), " climate_assessment_prepare.R: ", if (createdOutputCsv) "Created" else "Replaced",
  " climateAssessmentEmi '", climateAssessmentEmi, "'\n"
)
capture.output(cat(logMsg), file = logFile, append = TRUE)

#
# RUN CLIMATE ASSESSMENT
#
timeStartSetUpAssessment <- Sys.time()
# Set default values for the climate assessment config data in case they are not available for backward compatibility
if (is.null(cfg$climate_assessment_root)) cfg$climate_assessment_root <- "/p/projects/rd3mod/python/climate-assessment/src/"
if (is.null(cfg$climate_assessment_infiller_db)) cfg$climate_assessment_infiller_db <- "/p/projects/rd3mod/climate-assessment-files/1652361598937-ar6_emissions_vetted_infillerdatabase_10.5281-zenodo.6390768.csv"
if (is.null(cfg$climate_assessment_magicc_bin)) cfg$climate_assessment_magicc_bin <- "/p/projects/rd3mod/climate-assessment-files/magicc-v7.5.3/bin/magicc"
if (is.null(cfg$climate_assessment_magicc_prob_file_iteration)) cfg$climate_assessment_magicc_prob_file_iteration <- "/p/projects/rd3mod/climate-assessment-files/parsets/RCP20_50.json"

# The base name, that climate-assessment uses to derive it's output names
baseFn <- sub("\\.csv$", "", basename(climateAssessmentEmi))

# Auxiliary input data for climate-assessment and MAGICC7
infillingDatabaseFile <- normalizePath(cfg$climate_assessment_infiller_db, mustWork = TRUE)
probabilisticFile <- normalizePath(cfg$climate_assessment_magicc_prob_file_iteration, mustWork = TRUE)

# Extract the location of the climate-assessment scripts and the MAGICC binary from cfg.txt
scriptsDir <- normalizePath(file.path(cfg$climate_assessment_root, "scripts"))
magiccBinFile <- normalizePath(file.path(cfg$climate_assessment_magicc_bin))
magiccWorkersDir <- file.path(normalizePath(climateTempDir), "workers")
gamsRDir <- Sys.getenv("GAMSROOT")
if (nchar(gamsRDir) <= 0) {
  warning("Empty GAMSROOT environment variable")
}

# Read parameter sets file to ascertain how many parsets there are
allparsets <- read_yaml(probabilisticFile)
nparsets <- length(allparsets$configurations)

logMsg <- paste0(date(), " =================== SET UP climate-assessment scripts environment ===================\n")
capture.output(cat(logMsg), file = logFile, append = TRUE)

# Create working folder for climate-assessment files
dir.create(magiccWorkersDir, recursive = TRUE, showWarnings = FALSE)

#
# SET UP MAGICC ENVIRONMENT VARIABLES
#

# Character vector of all required MAGICC7 environment variables
magiccEnvs <- c(
  "MAGICC_EXECUTABLE_7"    = magiccBinFile, # Specifies the path to the MAGICC executable
  "MAGICC_WORKER_ROOT_DIR" = magiccWorkersDir, # Directory of magicc workers
  "MAGICC_WORKER_NUMBER"   = 1 # TODO: Get this from slurm or nproc
)

gamsEnvs <- c(
  "R_GAMS_SYSDIR" = gamsRDir
)

environmentVariables <- c(magiccEnvs, gamsEnvs)

# Check if all necessary environment variables are set
alreadySet <- lapply(Sys.getenv(names(environmentVariables)), nchar) > 0
# Only set those environment variables that are not already set
if (any(!alreadySet)) do.call(Sys.setenv, as.list(environmentVariables[!alreadySet]))

#
# BUILD climate-assessment RUN COMMANDS
#

expectedHarmInfFile <- file.path(
  climateTempDir,
  paste0(baseFn, "_harmonized_infilled.xlsx")
)

runHarmoniseAndInfillCmd <- paste(
  "python", file.path(scriptsDir, "run_harm_inf.py"),
  climateAssessmentEmi,
  climateTempDir,
  "--infilling-database", infillingDatabaseFile
)

runClimateEmulatorCmd <- paste(
  "python climate_assessment_openscm_run.py ",
  normalizePath(file.path(climateTempDir, paste0(baseFn, "_harmonized_infilled.csv"))),
  "--climatetempdir", climateTempDir,
  # Note: Option --year-filter-last requires https://github.com/gabriel-abrahao/climate-assessment/tree/yearfilter
  "--endyear", 2250,
  "--num-cfgs", nparsets,
  "--scenario-batch-size", 1,
  "--probabilistic-file", probabilisticFile
)


# Get conda environment folder
condaDir <- "/p/projects/rd3mod/python/environments/scm_magicc7"
# Command to activate the conda environment, changes depending on the cluster
if (file.exists("/p/system/modulefiles/defaults/piam/1.25")) {
  condaCmd <- paste0("module load conda/2023.09; source activate ", condaDir, ";")
} else {
  condaCmd <- paste0("module load anaconda/2023.09; source activate ", condaDir, ";")
}

logMsg <- paste0(
  date(), "  CLIMATE-ASSESSMENT ENVIRONMENT:\n",
  "  climateTempDir        = '", climateTempDir, "' exists? ", dir.exists(climateTempDir), "\n",
  "  baseFn                = '", baseFn, "'\n",
  "  probabilisticFile     = '", probabilisticFile, "' exists? ", file.exists(probabilisticFile), "\n",
  "  infillingDatabaseFile = '", infillingDatabaseFile, "' exists? ", file.exists(infillingDatabaseFile), "\n",
  "  scriptsDir            = '", scriptsDir, "' exists? ", dir.exists(scriptsDir), "\n",
  "  magiccBinFile         = '", magiccBinFile, "' exists? ", file.exists(magiccBinFile), "\n",
  "  magiccWorkersDir      = '", magiccWorkersDir, "' exists? ", dir.exists(magiccWorkersDir), "\n\n",
  "  condaCmd              = '", condaCmd, "'\n",
  "  ENVIRONMENT VARIABLES:\n",
  "  MAGICC_EXECUTABLE_7    = ", Sys.getenv("MAGICC_EXECUTABLE_7"), "\n",
  "  MAGICC_WORKER_ROOT_DIR = ", Sys.getenv("MAGICC_WORKER_ROOT_DIR"), "\n",
  "  MAGICC_WORKER_NUMBER   = ", Sys.getenv("MAGICC_WORKER_NUMBER"), "\n",
  "  R_GAMS_SYSDIR          = ", Sys.getenv("R_GAMS_SYSDIR"), "\n",
  date(), " =================== RUN climate-assessment infilling & harmonization ===================\n",
  runHarmoniseAndInfillCmd, "'\n"
)
capture.output(cat(logMsg), file = logFile, append = TRUE)
timeStopSetUpAssessment <- Sys.time()

############################# HARMONIZATION/INFILLING #############################

timeStartHarmInf <- Sys.time()
system(paste(condaCmd, runHarmoniseAndInfillCmd, "&>>", logFile))
timeStopHarmInf <- Sys.time()

############################# RUNNING MODEL #############################

logMsg <- paste0(
  date(), "  Found ", nparsets, " nparsets, start climate-assessment climate emulator step\n",
  runHarmoniseAndInfillCmd, "\n",
  date(), " =================== RUN climate-assessment model ============================\n",
  runClimateEmulatorCmd, "'\n"
)
capture.output(cat(logMsg), file = logFile, append = TRUE)

timeStartEmulation <- Sys.time()
system(paste(condaCmd, runClimateEmulatorCmd, "&>>", logFile))
timeStopEmulation <- Sys.time()

############################# POSTPROCESS CLIMATE OUTPUT #############################
climateAssessmentOutput <- file.path(
  climateTempDir,
  paste0(baseFn, "_harmonized_infilled_IAMC_climateassessment.xlsx")
)

assessmentData <- read.quitte(climateAssessmentOutput)
# usePeriods <- as.numeric(grep("[0-9]+", names(climateAssessmentInputData), value = TRUE))
usePeriods <- unique(assessmentData[["period"]])
logMsg <- paste0(
  " =================== POSTPROCESS climate-assessment output ==================\n",
  date(), "Read climate assessment output file '", climateAssessmentOutput, "' file containing ",
  length(usePeriods), " years\n"
)
capture.output(cat(logMsg), file = logFile, append = TRUE)

timeStartPostProcessing <- Sys.time()
# thesePlease contains all variables IN MAGICC7 format that oughta be written to GDX as NAMES and the GDX file name
# as VALUES. If the variable is not found in the input data, it will be ignored. If you want the the same variable in
# mutliple files, add another entry to the list. TODO: This could config file...
associateVariablesAndFiles <- as.data.frame(rbind(
  c(
    # magicc7Variable = "AR6 climate diagnostics|Surface Temperature (GSAT)|MAGICCv7.5.3|50.0th Percentile",
    magicc7Variable = "Surface Air Temperature Change",
    gamsVariable = "pm_globalMeanTemperature",
    fileName = "p15_magicc_temp"
  ),
  c(
    magicc7Variable = "Effective Radiative Forcing|Anthropogenic",
    gamsVariable = "p15_forc_magicc",
    fileName = "p15_forc_magicc"
  )
)) %>%
  mutate(remindVariable = sapply(
    .data$magicc7Variable,
    renameVariableMagicc7ToRemind,
    simplify = TRUE, USE.NAMES = FALSE
  ))

# Use the variable/file association to determine which variables shall be extracted from the MAGICC7 data
thesePlease <- unique(associateVariablesAndFiles$magicc7Variable)
relevantData <- assessmentData %>%
  # Exlude all other variables
  filter(variable %in% thesePlease & period %in% usePeriods) %>%
  # Interpolate missing periods: TODO is this actually necessary? We only check for periods in the data anyway..
  interpolate_missing_periods(usePeriods, expand.values = FALSE) %>%
  # Transform data from long to wide format such that yearly values are given in individual columns
  pivot_wider(names_from = "period", values_from = "value") %>%
  # Rename variables to REMIND-style names
  mutate(variable = sapply(.data$variable, renameVariableMagicc7ToRemind, simplify = TRUE, USE.NAMES = FALSE))

timeStopPostProcessing <- Sys.time()

# Loop through each file name given in associateVariablesAndFiles and write the associated variables to GDX files
# Note: This arrangement is capable of writing multiple variables to the same GDX file
timeStartWriteGdx <- Sys.time()
for (currentFn in unique(associateVariablesAndFiles$fileName)) {
  whatToWrite <- associateVariablesAndFiles %>%
    filter(.data$fileName == currentFn) %>%
    select(remindVariable, gamsVariable)
  # Build a column vector of the variable values
  gdxData <- cbind(
    # First column has to be enumaration of values 1..n(variable values)
    1:length(usePeriods),
    # Subsequent columns have to be the actual variable values
    relevantData %>%
      filter(.data$variable %in% whatToWrite$remindVariable) %>%
      select(all_of(as.character(usePeriods))) %>%
      t()
  )
  # Drop row names (period/years), since they are provided in the GDX file as "uels"
  rownames(gdxData) <- NULL
  # Write the GDX file
  # First, create a list of lists that in turn contain the actual data to be written
  wgdx.lst(
    currentFn,
    llist <- purrr::map(2:ncol(gdxData), function(idx) {
      list(
        name = whatToWrite$gamsVariable[idx - 1],
        type = "parameter",
        dim = 1,
        val = gdxData[, c(1, idx)],
        form = "sparse",
        uels = list(usePeriods),
        domains = "tall"
      )
    })
  )
  logMsg <- paste0(date(), " Wrote '", currentFn, "'\n")
  cat(logMsg)
  capture.output(cat(logMsg), file = logFile, append = TRUE)
}
timeStopWriteGdx <- Sys.time()

# Archive the data: Get the list of xlsx and csv files in climateTempDir and the relevant gdx-es in outputDir
timeStartArchive <- Sys.time()
if (archiveClimateAssessmentData) {
  climateAssessmentFiles <- list.files(climateTempDir, pattern = "\\.(xlsx|csv)$", full.names = TRUE)
  climateAssessmentFiles <- c(
    climateAssessmentFiles,
    file.path(outputDir, "p15_forc_magicc.gdx"),
    file.path(outputDir, "p15_magicc_temp.gdx")
  )
  # Copy each file to climateArchiveDir
  lapply(climateAssessmentFiles, function(file) {
    file.copy(file, file.path(climateArchiveDir, basename(file)))
  })
  # Create a tar archive of the directory Compress the tar archive using xz. Need to switch working directory here so
  # tar does not include the full path directory structure in the archive :facepalm:
  oldwd <- getwd()
  setwd(climateArchiveDir)
  tarfile <- paste0(climateArchiveDir, ".tar.gz")
  tar(tarfile, files = basename(climateAssessmentFiles), compression = "gzip")
  setwd(oldwd)
  # Delete the archive directory (i.e. <outputdir>/climate_assessment_data/archive/iteration_<timestamp>, not the
  # <outputdir>/climate_assessment_data/archive directory itself)
  unlink(climateArchiveDir, recursive = TRUE)
  logMsg <- paste0(date(), " Archived climate assessment data to '", tarfile, "'\n")
  cat(logMsg)
  capture.output(cat(logMsg), file = logFile, append = TRUE)
}
timeStopArchive <- Sys.time()
logMsg <- paste0(date(), " Done writing GDX files\n")

############################# CLEAN UP WORKERS FOLDER ##########################
# openscm_runner not remnove up temp dirs. Do this manually since we keep running into file ownership issues
workersFolder <- file.path(climateTempDir, "workers")  # replace with your directory path
if (dir.exists(workersFolder)) {
  # Check if directory is empty
  if (length(list.files(workersFolder)) == 0) {
    # Remove directory. Option recursive must be TRUE for some reason, otherwise unlink won't do its job
    unlink(workersFolder, recursive = TRUE)
    logMsg <- paste0(logMsg, date(), "  Removed workers folder '", workersFolder, "'\n")
  }
}

logMsg <- paste0(logMsg,
  date(), " Runtime report: ", paste0("iteration_", timestamp, "\n"),
  "\tRuntime set_up_script: ",
  difftime(timeStopSetUpScript, timeStartSetUpScript, units = "secs"), "s\n",
  "\tRuntime preprocessing: ",
  difftime(timeStopPreprocessing, timeStartPreprocessing, units = "secs"), "s\n",
  "\tRuntime set_up_assessment: ",
  difftime(timeStopSetUpAssessment, timeStartSetUpAssessment, units = "secs"), "s\n",
  "\tRuntime harmonization_infilling: ",
  difftime(timeStopHarmInf, timeStartHarmInf, units = "secs"), "s\n",
  "\tRuntime emulation: ",
  difftime(timeStopEmulation, timeStartEmulation, units = "secs"), "s\n",
  "\tRuntime postprocessing: ",
  difftime(timeStopPostProcessing, timeStartPostProcessing, units = "secs"), "s\n",
  "\tRuntime write_gdx: ",
  difftime(timeStopWriteGdx, timeStartWriteGdx, units = "secs"), "s\n",
  "\tRuntime archive_data: ",
  difftime(timeStopArchive, timeStartArchive, units = "secs"), "s\n",
  "\tRuntime total: ",
  difftime(timeStopArchive, timeStartSetUpScript, units = "secs"), "s\n",
  date(), " climate_assessment_run.R: Done\n"
)
capture.output(cat(logMsg), file = logFile, append = TRUE)
