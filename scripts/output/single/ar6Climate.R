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

# TODO: REMOVE THIS LINE. piamInterfaces should be installed as a package on the cluster
devtools::load_all("/p/tmp/tonnru/piamInterfaces/") 

############################# BASIC CONFIGURATION #############################
gdxName <- "fulldata.gdx"             # name of the gdx
cfgName <- "cfg.txt"                  # cfg file for getting file paths

if (!exists("source_include")) {
  # Define arguments that can be read from command line
  outputdir <- "."
  readArgs("outputdir", "gdxName", "gdx_ref_name", "gdx_refpolicycost_name")
}

cfgPath               <- file.path(outputdir, cfgName)
logfile               <- file.path(outputdir, "log_climate.txt") # specific log for python steps
scenario              <- getScenNames(outputdir)
remindReportingFile   <- file.path(outputdir, paste0("REMIND_generic_", scenario, ".mif"))
climateAssessmentYaml <- file.path(system.file("iiasaTemplates", package = "piamInterfaces"),
                                   "climate_assessment_variables.yaml")
climateAssessmentCSV  <- file.path(outputdir, paste0("ar6csv_", scenario, ".csv"))

# Read the cfg to get the location of MAGICC-related files
cfg <- read_yaml(cfgPath)

############################# PREPARING EMISSIONS INPUT #############################

cat(date(), " ar6Climate.R: Extracting REMIND emission data\n")

climateAssessmentInputData <- as.quitte(remindReportingFile) %>%
  filter(region %in% c("GLO", "World")) %>%
  generateIIASASubmission(
    mapping = "AR6",
    outputFilename = NULL,
    iiasatemplate = climateAssessmentYaml,
    logFile = logfile
  ) %>%
  mutate(region = factor("World")) %>%
  rename_with(str_to_title) %>%
  pivot_wider(names_from = "Period", values_from = "Value") %>%
  write_csv(climateAssessmentCSV, quote = "none")

cat(date(), paste0(" ar6Climate.R: Wrote to'", climateAssessmentCSV, "' for climate-assessment\n"))

############################# PYTHON/MAGICC SETUP #############################
# These files are supposed to be all inside cfg$climate_assessment_files_dir in a certain structure
# TODO: Make this even more flexible by explictly setting them in default.cfg
probabilisticFile     <- file.path(cfg$climate_assessment_files_dir,
                                   "/parsets/0fd0f62-derived-metrics-id-f023edb-drawnset.json")
infillingDatabaseFile <- file.path(cfg$climate_assessment_files_dir,
                                   "/1652361598937-ar6_emissions_vetted_infillerdatabase_10.5281-zenodo.6390768.csv")
magiccBinFile         <- file.path(cfg$climate_assessment_files_dir, "/magicc-v7.5.3/bin/magicc")
scriptsFolder         <- file.path(cfg$climate_assessment_root, "scripts/")

# Create working folder for climate-assessment files
workfolder <- file.path(outputdir, "climate-temp")
dir.create(workfolder, showWarnings = FALSE)

# Set relevant environment variables and create a MAGICC worker directory
Sys.setenv(MAGICC_EXECUTABLE_7 = magiccBinFile)
Sys.setenv(MAGICC_WORKER_ROOT_DIR = paste0(normalizePath(workfolder), "/workers/")) # Has to be an absolute path
Sys.setenv(MAGICC_WORKER_NUMBER = 1) # TODO: Get this from slurm or nproc

dir.create(Sys.getenv("MAGICC_WORKER_ROOT_DIR"), recursive = TRUE, showWarnings = FALSE)

# The base name, that climate-assessment uses to derive it's output names
basefname <- sub("\\.csv$", "", basename(ar6csvfpath))

# Set up another log file for the python output
logmsg <- paste0(date(), " Created log\n=================== EXECUTING climate-assessment scripts ===================n")
cat(logmsg)
capture.output(cat(logmsg), file = logfile, append = FALSE)

############################# HARMONIZATION/INFILLING #############################
logmsg <- paste0(date(), " Started harmonization\n")
cat(logmsg)
capture.output(cat(logmsg), file = logfile, append = TRUE)

cmd <- paste0("python ", scriptsFolder, "run_harm_inf.py ", ar6csvfpath, " ", workfolder, " ",
              "--no-inputcheck --infilling-database ", infillingDatabaseFile)
system(cmd)

############################# RUNNING MODEL #############################
logmsg <- paste0(date(), " Started runs\n")
cat(logmsg)
capture.output(cat(logmsg), file = logfile, append = TRUE)

# Read parameter sets file to ascertain how many parsets there are
allparsets <- read_yaml(probabilisticFile)
nparsets <- length(allparsets$configurations)
cmd <- paste0("python ", scriptsFolder, "run_clim.py ", workfolder, "/", basefname,
              "_harmonized_infilled.csv ", workfolder, " --num-cfgs ", nparsets, " --scenario-batch-size ", 1,
              " --probabilistic-file ", probabilisticFile)
system(cmd)

############################# READING CLIMATE OUTPUT #############################
climoutfpath <- file.path(workfolder, paste0(basefname, "_harmonized_infilled_IAMC_climateassessment.xlsx"))
climdata <- read.quitte(climoutfpath)

############################# APPEND TO REMIND MIF #############################
# Filter only periods used in REMIND, so that it doesn't expand the original mif
useperiods <- unique(read.quitte(remindReportingFile)$period)
climdata <- climdata[climdata$period %in% useperiods, ]
climdata <- interpolate_missing_periods(climdata, useperiods, expand.values = FALSE)
write.mif(climdata, remindReportingFile, append = TRUE)
