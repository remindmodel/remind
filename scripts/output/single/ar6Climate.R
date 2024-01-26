# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(madrat)
library(remind2)
library(quitte)
library(piamInterfaces)
library(yaml)
library(readr)
library(lucode2)
library(stringr)

# TODO: REMOVE THIS LINE. piamInterfaces should be installed as a package on the cluster
devtools::load_all("/p/tmp/tonnru/piamInterfaces/") 

############################# BASIC CONFIGURATION #############################

logmsg <- paste0(date(), " =================== CONFIGURATION STARTED ==================================\n")
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = FALSE)

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
climateAssessmentYaml <- file.path(system.file("iiasaTemplates", package = "piamInterfaces"),
                                   "climate_assessment_variables.yaml")
climateAssessmentEmi  <- file.path(outputdir, paste0("ar6_climate_assessment_", scenario, ".csv"))

############################# PREPARING EMISSIONS INPUT #############################

logmsg <- paste0(
  "  cfgPath = '",              cfgPath,                "' exists? ", file.exists(cfgPath), "\n",
  "  logFile = '",              logFile,                "' exists? ", file.exists(logFile), "\n",
  "  scenario = '",              scenario, "\n",
  "  remindReportingFile = '",   remindReportingFile,   "' exists? ", file.exists(remindReportingFile), "\n",
  "  climateAssessmentYaml = '", climateAssessmentYaml, "' exists? ", file.exists(climateAssessmentYaml), "\n",
  "  climateAssessmentEmi = '",  climateAssessmentEmi,  "' exists? ", file.exists(climateAssessmentEmi), "\n",
  date(), " =================== EXTRACT REMIND emission data ===========================\n",
  "  ar6Climate.R: Extracting REMIND emission data\n"
)
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = FALSE)

climateAssessmentInputData <- as.quitte(remindReportingFile) %>%
  filter(region %in% c("GLO", "World")) %>%
  generateIIASASubmission(
    mapping = "AR6",
    outputFilename = NULL,
    iiasatemplate = climateAssessmentYaml,
    logFile = logFile
  ) %>%
  mutate(region = factor("World")) %>%
  rename_with(str_to_title) %>%
  pivot_wider(names_from = "Period", values_from = "Value") %>%
  write_csv(climateAssessmentEmi, quote = "none")

logmsg <- paste0(
  date(), "  ar6Climate.R: Wrote REMIND emission data to '", climateAssessmentEmi, "' for climate-assessment\n"
)
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = FALSE)

############################# PYTHON/MAGICC SETUP #############################

# Read the cfg to get the location of MAGICC-related files
cfg <- read_yaml(cfgPath)

# All climate-assessment files will be written to this folder
climateAssessmentFolder <- normalizePath(file.path(outputdir, "climate-assessment-data"))
dir.create(climateAssessmentFolder, showWarnings = FALSE)

# The base name, that climate-assessment uses to derive it's output names
baseFileName <- sub("\\.csv$", "", basename(climateAssessmentEmi))

# These files are supposed to be all inside cfg$climate_assessment_files_dir in a certain structure
probabilisticFile     <- normalizePath(file.path(cfg$climate_assessment_files_dir,
                                       "parsets", "0fd0f62-derived-metrics-id-f023edb-drawnset.json"))
infillingDatabaseFile <- normalizePath(file.path(cfg$climate_assessment_files_dir,
                                      "1652361598937-ar6_emissions_vetted_infillerdatabase_10.5281-zenodo.6390768.csv"))
scriptsFolder         <- normalizePath(file.path(cfg$climate_assessment_root, "scripts"))
magiccBinFile         <- normalizePath(file.path(cfg$climate_assessment_magicc_bin))
magiccWorkersFolder   <- file.path(normalizePath(climateAssessmentFolder), "workers")

logmsg <- paste0(date(), " =================== SET UP climate-assessment scripts environment ===================\n")
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = FALSE)

# Create working folder for climate-assessment files
dir.create(magiccWorkersFolder, recursive = TRUE, showWarnings = FALSE)

# Set relevant environment variables and create a MAGICC worker directory
Sys.setenv(MAGICC_EXECUTABLE_7 = magiccBinFile)
Sys.setenv(MAGICC_WORKER_ROOT_DIR = magiccWorkersFolder) # Has to be an absolute path
Sys.setenv(MAGICC_WORKER_NUMBER = 1) # TODO: Get this from slurm or nproc

logmsg <- paste0(
  "  climateAssessmentFolder = '", climateAssessmentFolder, "' exists? ", dir.exists(climateAssessmentFolder), "\n",
  "  baseFileName = '",            baseFileName, "\n",
  "  probabilisticFile = '",       probabilisticFile,       "' exists? ", file.exists(probabilisticFile), "\n",
  "  infillingDatabaseFile = '",   infillingDatabaseFile,   "' exists? ", file.exists(infillingDatabaseFile), "\n",
  "  scriptsFolder = '",           scriptsFolder,           "' exists? ", dir.exists(scriptsFolder), "\n",
  "  magiccBinFile = '",           magiccBinFile,           "' exists? ", file.exists(magiccBinFile), "\n",
  "  magiccWorkersFolder = '",     magiccWorkersFolder,     "' exists? ", dir.exists(magiccWorkersFolder), "\n\n",
  "  ENVIRONMENT VARIABLES:\n",
  "  MAGICC_EXECUTABLE_7    = ", Sys.getenv("MAGICC_EXECUTABLE_7") ,"\n",
  "  MAGICC_WORKER_ROOT_DIR = ", Sys.getenv("MAGICC_WORKER_ROOT_DIR") ,"\n",
  "  MAGICC_WORKER_NUMBER   = ", Sys.getenv("MAGICC_WORKER_NUMBER") ,"\n",
  date(), " =================== EXECUTING climate-assessment scripts ===================\n"
)
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = FALSE)

############################# HARMONIZATION/INFILLING #############################
logmsg <- paste0(date(), "  Startclimate-assessment harmonization\n")
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = TRUE)

run_harm_inf_cmd <- paste(
  "python", file.path(scriptsFolder, "run_harm_inf.py"),
  climateAssessmentEmi,
  climateAssessmentFolder,
  "--no-inputcheck",
  "--infilling-database", infillingDatabaseFile
)
cat(run_harm_inf_cmd, "\n")
# system(run_harm_inf_cmd)

############################# RUNNING MODEL #############################
# Read parameter sets file to ascertain how many parsets there are
allparsets <- read_yaml(probabilisticFile)
nparsets   <- length(allparsets$configurations)

logmsg <- paste0(
  date(), "  Found ", nparsets, " nparsets, start climate-assessment model runs\n", run_harm_inf_cmd, "\n")
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = TRUE)

run_clim_cmd <- paste(
  "python", file.path(scriptsFolder, "run_clim.py"),
  normalizePath(file.path(climateAssessmentFolder, paste0(baseFileName, "_harmonized_infilled.csv"))),
  climateAssessmentFolder,
  "--num-cfgs", nparsets,
  "--scenario-batch-size", 1,
  "--probabilistic-file", probabilisticFile
)
cat(run_clim_cmd, "\n")
# system(run_clim_cmd)

############################# POSTPROCESS CLIMATE OUTPUT #############################
climateAssessmentOutput <- file.path(
  climateAssessmentFolder,
  paste0(baseFileName, "_harmonized_infilled_IAMC_climateassessment.xlsx")
)

logmsg <- paste0(
  date(), "  climate-assessment finished\n",
  date(), " =================== POSTPROCESS climate-assessment output ==================\n",
  "  climateAssessmentOutput = '", climateAssessmentOutput, "' exists? ", dir.exists(climateAssessmentOutput), "\n"
)
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = TRUE)


############################# APPEND TO REMIND MIF #############################
# Filter only periods used in REMIND, so that it doesn't expand the original mif
usePeriods <- unique(read.quitte(remindReportingFile)$period)

# climateAssessmentData <- read.quitte(climateAssessmentOutput)
# climateAssessmentData <- climateAssessmentData[climateAssessmentData$period %in% usePeriods, ]
# climateAssessmentData <- interpolate_missing_periods(climateAssessmentData, usePeriods, expand.values = FALSE)
# write.mif(climateAssessmentData, remindReportingFile, append = TRUE)

climateAssessmentData <- read.quitte(climateAssessmentOutput) %>%
  filter(period %in% usePeriods) %>%
  interpolate_missing_periods(usePeriods, expand.values = FALSE) %>%
  write.mif(remindReportingFile, append = TRUE)

logmsg <- paste0(
  date(), " postprocessing done! Results appended to REMIND mif '", remindReportingFile, "'\n",
  "ar6Climate.R finished\n"
)
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = TRUE)
