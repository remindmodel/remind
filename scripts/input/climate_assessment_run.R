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
require(lucode2)
require(purrr)
require(gdxrrw) # Needs an environmental variable to be set, see below

renameVariableMagicc7ToRemind <- function(varName) {
   varName <- gsub("|MAGICCv7.5.3", "", varName, fixed = TRUE)
   varName <- gsub("AR6 climate diagnostics|", "MAGICC7 AR6|", varName, fixed = TRUE)
   return(varName)
}

# This script is meant to run the full IIASA climate assessment using a single parameter set,
# meant to be used between REMIND iterations

outputDir <- getwd()

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
if (is.null(cfg$climate_assessment_infiller_db)) cfg$climate_assessment_infiller_db <- "/p/projects/rd3mod/climate-assessment-files/1652361598937-ar6_emissions_vetted_infillerdatabase_10.5281-zenodo.6390768.csv"
if (is.null(cfg$climate_assessment_magicc_bin)) cfg$climate_assessment_magicc_bin <- "/p/projects/rd3mod/climate-assessment-files/magicc-v7.5.3/bin/magicc"
if (is.null(cfg$climate_assessment_magicc_prob_file_iteration)) cfg$climate_assessment_magicc_prob_file_iteration <- "/p/projects/rd3mod/climate-assessment-files/parsets/RCP20_50.json"
if (is.null(cfg$climate_assessment_r_gams_dir)) cfg$climate_assessment_r_gams_dir <- "/p/system/packages/gams/43.4.1"

# The base name, that climate-assessment uses to derive it's output names
baseFn <- sub("\\.csv$", "", basename(climateAssessmentEmi))

# Auxiliary input data for climate-assessment and MAGICC7
infillingDatabaseFile <- normalizePath(cfg$climate_assessment_infiller_db, mustWork = TRUE)
probabilisticFile <- normalizePath(cfg$climate_assessment_magicc_prob_file_iteration, mustWork = TRUE)

# Extract the location of the climate-assessment scripts and the MAGICC binary from cfg.txt
scriptsDir <- normalizePath(file.path(cfg$climate_assessment_root, "scripts"))
magiccBinFile <- normalizePath(file.path(cfg$climate_assessment_magicc_bin))
magiccWorkersDir <- file.path(normalizePath(climateTempDir), "workers")
gamsRDir <- normalizePath(cfg$climate_assessment_r_gams_dir)

# Read parameter sets file to ascertain how many parsets there are
allparsets <- read_yaml(probabilisticFile)
nparsets <- length(allparsets$configurations)

logMsg <- paste0(date(), " =================== SET UP climate-assessment scripts environment ===================\n")
cat(logMsg)
capture.output(cat(logMsg), file = logFile, append = TRUE)

# Create working folder for climate-assessment files
dir.create(magiccWorkersDir, recursive = TRUE, showWarnings = FALSE)

#
# SET UP MAGICC ENVIRONMENT VARIABLES
#

# Character vector of all required MAGICC7 environment variables
magiccEnvs <- c(
    "MAGICC_EXECUTABLE_7"    = magiccBinFile,    # Specifies the path to the MAGICC executable
    "MAGICC_WORKER_ROOT_DIR" = magiccWorkersDir, # Directory of magicc workers
    "MAGICC_WORKER_NUMBER"   = 1                 # TODO: Get this from slurm or nproc
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

logMsg <- paste0(
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
    "  R_GAMS_SYSDIR          = ", Sys.getenv("R_GAMS_SYSDIR"), "\n",
    date(), " =================== RUN climate-assessment infilling & harmonization ===================\n",
    runHarmoniseAndInfillCmd, "'\n"
)
cat(logMsg)
capture.output(cat(logMsg), file = logFile, append = TRUE)

############################# HARMONIZATION/INFILLING #############################

timeStartHarmInf <- Sys.time()
system(runHarmoniseAndInfillCmd)
timeStopHarmInf <- Sys.time()

logMsg <- paste0(date(), "  Done with harmonization & infilling in ", timeStopHarmInf - timeStartHarmInf, "s\n")
cat(logMsg)
capture.output(cat(logMsg), file = logFile, append = TRUE)

############################# RUNNING MODEL #############################

logMsg <- paste0(
    date(), "  Found ", nparsets, " nparsets, start climate-assessment climate emulator step\n",
    runHarmoniseAndInfillCmd, "\n",
    date(), " =================== RUN climate-assessment model ============================\n",
    runClimateEmulatorCmd, "'\n"
)
cat(logMsg)
capture.output(cat(logMsg), file = logFile, append = TRUE)

timeStartEmulation <- Sys.time()
system(runClimateEmulatorCmd)
timeStopEmulation <- Sys.time()

############################# POSTPROCESS CLIMATE OUTPUT #############################
climateAssessmentOutput <- file.path(
    climateTempDir,
    paste0(baseFn, "_harmonized_infilled_IAMC_climateassessment.xlsx")
)

assessmentData <- read.quitte(climateAssessmentOutput)
usePeriods <- unique(assessmentData$period)
logMsg <- paste0(
    date(), "  climate-assessment climate emulator finished in ", timeStopEmulation - timeStartEmulation, "s\n",
    " =================== POSTPROCESS climate-assessment output ==================\n",
    date(), "Read climate assessment output file '", climateAssessmentOutput, "' file containing ", 
    length(usePeriods), " years\n"
)
cat(logMsg)
capture.output(cat(logMsg), file = logFile, append = TRUE)

# thesePlease contains all variables IN MAGICC7 format that oughta be written to GDX as NAMES and the GDX file name
# as VALUES. If the variable is not found in the input data, it will be ignored. If you want the the same variable in 
# mutliple files, add another entry to the list. TODO: This could config file...
associateVariablesAndFiles <- as.data.frame(rbind(
        c(
            magicc7Variable = "AR6 climate diagnostics|Surface Temperature (GSAT)|MAGICCv7.5.3|50.0th Percentile",
            gamsVariable = "pm_globalMeanTemperature",
            fileName = "p15_magicc_temp"
        ),
        c(
            magicc7Variable = "AR6 climate diagnostics|Effective Radiative Forcing|Basket|Anthropogenic|MAGICCv7.5.3|50.0th Percentile",
            gamsVariable = "p15_forc_magicc",
            fileName = "p15_forc_magicc"
        ) #,
        # c(
        #    magicc7Variable = "AR6 climate diagnostics|Atmospheric Concentrations|CO2|MAGICCv7.5.3|50.0th Percentile",
        #    gamsVariable = "pm_co2_conc",
        #    fileName = "wdeleteme"
        # )
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

# Loop through each file name given in associateVariablesAndFiles and write the associated variables to GDX files
# Note: This arrangement is capable of writing multiple variables to the same GDX file
for (currentFn in unique(associateVariablesAndFiles$fileName)) {
    # gamsVariable <- gdxFilesAndRemindVariables[[fileName]]
    #cat(paste0(currentFn, "\n"))
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
logMsg <- paste0(
    date(), " Done writing GDX files\n",
    date(), " climate-assessment: Finished all\n"
)
cat(logMsg)
capture.output(cat(logMsg), file = logFile, append = TRUE)

