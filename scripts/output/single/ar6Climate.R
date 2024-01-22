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
library(lucode2)
library(readxl) # GA: Wont be necessary after https://github.com/iiasa/climate-assessment/pull/43 goes into release

############################# BASIC CONFIGURATION #############################
gdxName <- "fulldata.gdx"             # name of the gdx
cfgName <- "cfg.txt"                  # cfg file for getting file paths


if (!exists("source_include")) {
  # Define arguments that can be read from command line
  outputdir <- "."
  readArgs("outputdir", "gdxName", "gdx_ref_name", "gdx_refpolicycost_name")
}

gdx                 <- file.path(outputdir, gdxName)
cfgPath             <- file.path(outputdir, cfgName)
logfile             <- file.path(outputdir, "climate.log") # specific log for python steps
scenario            <- getScenNames(outputdir)
remindReportingFile <- file.path(outputdir, paste0("REMIND_generic_", scenario, ".mif"))

print(getwd())
############################# PREPARING EMISSIONS INPUT #############################

# Read the cfg to get the location of MAGICC-related files
cfg <- read_yaml(cfgPath)

# Read the GDX and run reportEmi
cat(date(), " ar6Climate.R: Running reportEmi \n")
emimag <- reportEmi(gdx)

# Convert to quitte and add metadata
emimif <- as.quitte(emimag)
emimif["scenario"] <- scenario #TODO: Get scenario name from cfg

# Write the raw emissions mif
# TODO: This wouldn't be necessary if we added an option to generateIIASASubmission
# to work with a quitte object directly, not a file path
cat(date(), " ar6Climate.R: Writing raw emissions mif in file: \n")
emimifpath <- paste0(outputdir, "/", "emimif_raw_", scenario, ".mif")
cat(date(), " ar6Climate.R: ", emimifpath, "\n")
write.mif(emimif, emimifpath)

# Get the emissions in AR6 format
# This seems to work with just the reportEmi mif
cat(date(), " ar6Climate.R: Running generateIIASASubmission to generate AR6 mif in file:\n")
emimifar6fpath <- paste0(outputdir, "/", "emimif_ar6_", scenario, ".mif")
cat(date(), " ar6Climate.R: ", emimifar6fpath, "\n")
generateIIASASubmission(emimifpath, mapping = "AR6", outputDirectory = outputdir,
                        outputFilename = basename(emimifar6fpath), logFile = paste0(outputdir, "/missing.log"))

# Read in AR6 mif
cat(date(), " ar6Climate.R: Reading AR6 mif and preparing csv for climate-assessment\n")
ar6mif <- read.quitte(emimifar6fpath)

# Get it ready for climate-assessment: capitalized titles, just World, comma separator
colnames(ar6mif) <- paste(toupper(substr(colnames(ar6mif), 1, 1)),
                          substr(colnames(ar6mif), 2, nchar(colnames(ar6mif))), sep = "")
ar6mif <- ar6mif[ar6mif$Region %in% c("GLO", "World"), ]
ar6mif$Region <- "World"

# Long to wide
outcsv <- reshape(as.data.frame(ar6mif),
                  direction = "wide", timevar = "Period", v.names = "Value",
                  idvar = c("Model", "Variable", "Scenario", "Region", "Unit"))
colnames(outcsv) <- gsub("Value.", "", colnames(outcsv))

# Write output in csv for climate-assessment
cat(date(), " ar6Climate.R: Writing csv for climate-assessment\n")
ar6csvfpath <- paste0(outputdir, "/", "ar6csv_", scenario, ".csv")
write.csv(outcsv, ar6csvfpath, row.names = FALSE, quote = FALSE)

############################# PYTHON/MAGICC SETUP #############################
# These files are supposed to be all inside cfg$climate_assessment_files_dir in a certain structure
# TODO: Make this even more flexible by explictly setting them in default.cfg
probabilisticFile     <- file.path(cfg$climate_assessment_files_dir,
                                   "/parsets/0fd0f62-derived-metrics-id-f023edb-drawnset.json")
infillingDatabaseFile <- file.path(cfg$climate_assessment_files_dir, 
                                   "/1652361598937-ar6_emissions_vetted_infillerdatabase_10.5281-zenodo.6390768.csv")
magiccBinFile         <- file.path(cfg$climate_assessment_files_dir, "/magicc-v7.5.3/bin/magicc")
scriptsFolder         <- "/p/projects/rd3mod/python/climate-assessment/scripts"

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
