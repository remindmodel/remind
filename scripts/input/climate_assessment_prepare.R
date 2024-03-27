require(remind2)
require(quitte)
require(piamInterfaces)
require(yaml)
require(tidyverse)
# require(madrat)
library(lucode2)

# Rscript climate_assessment_run_all.sh [gdxpath] [cfgpath] [temppath] [iterationIdx]

#
# READ COMMAND LINE ARGUMENTS
#
args <- commandArgs(trailingOnly = T)
# args <- c("fulldata.gdx", "cfg.txt", "climate-temp", "log_climate_dummy.log")

gdxPath <- args[1]
cfgPath <- args[2]
climateTempDir <- args[3]
logFile <- args[4]
# iterationIdx <- as.numeric(args[4])

logMsg <- paste0(
    date(), " climate_assessment_prepare.R: Using\n",
    "gdxPath        '", gdxPath, "'\n",
    "config         '", cfgPath, "'\n",
    "climateTempDir '", climateTempDir, "'\n"
)
cat(logMsg)
capture.output(cat(logMsg), file = logFile, append = TRUE)

# Get the scenario name from the cfg
cfg <- read_yaml(cfgPath)
scenarioName <- cfg$title

# Set up climate-assessment related configuration and output files
climateAssessmentYaml <- file.path(system.file(package = "piamInterfaces"), "iiasaTemplates", "climate_assessment_variables.yaml")
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
    "Start reportEmi"
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
    date(), " climate_assessment_prepare.R: ", if (createdOutputCsv) "Created" else "Replaced", " climateAssessmentEmi '", climateAssessmentEmi, "'\n"
)
cat(logMsg)
capture.output(cat(logMsg), file = logFile, append = TRUE)
