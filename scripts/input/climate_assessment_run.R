# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
#!/bin/bash

# This script is meant to run the full IIASA climate assessment using a single parameter set,
# meant to be used between REMIND iterations

outputDir <- getwd()

logFile <- file.path(outputDir, paste0("log_climate_", format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), ".txt"))
if (!file.exists(logFile)) {
    file.create(logFile)
    createdLogFile <- TRUE
} else {
    createdLogFile <- FALSE
}

climateTempDir <- file.path(outputDir, "climate-temp")
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

# ================  Run postprocessing on GDX
#
# REPLACE THESE LINES WITH THE ACTUAL POSTPROCESSING COMMANDS
#
cmd <- paste("Rscript climate_assessment_prepare.R", gdxPath, cfgPath, climateTempDir, logFile)
system(cmd)
climateAssessmentEmi <- file.path(climateTempDir, "ar6_climate_assessment_SSP2EU-NPi-ar6.csv")
#
# CONTINUE HERE
#

CLIMATE_ASSESSMENT_FILES_DIR <- "/p/projects/rd3mod/climate-assessment-files/"
probabilistic_file <- paste0(CLIMATE_ASSESSMENT_FILES_DIR, "parsets/RCP20_50.json")

sfolder="/p/projects/piam/abrahao/scratch/iiasa/climate-assessment/scripts/" #TODO: Get the one used in the renv


infilling_database_file=paste0(CLIMATE_ASSESSMENT_FILES_DIR,"/1652361598937-ar6_emissions_vetted_infillerdatabase_10.5281-zenodo.6390768.csv")

# Set relevant environment variables and create a MAGICC worker directory
Sys.setenv(MAGICC_EXECUTABLE_7=paste0(CLIMATE_ASSESSMENT_FILES_DIR,"/magicc-v7.5.3/bin/magicc"))
Sys.setenv(MAGICC_WORKER_ROOT_DIR=normalizePath(paste0(climateTempDir,"/workers/"))) # Has to be an absolute path
dir.create(Sys.getenv("MAGICC_WORKER_ROOT_DIR"), recursive = T, showWarnings = F)
Sys.setenv(MAGICC_WORKER_NUMBER=1) # TODO: Get this from slurm or nproc

#climateAssessmentEmi <- paste0(climateTempDir,"/emimif_ar6.csv")
basefname <- sub("\\.csv$","",basename(climateAssessmentEmi))

# Set up a log
logmsg <- paste0(date(), " Created log\n================================ EXECUTING climate_assessment_run.R =================================\n")
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = F)


# ================  Harmonization and infilling step
# TODO: This can take up to a minute, and shouldn't change much between
# REMIND iterations. Lets try to replace this step in most iterations with
# the simple scaling method in the script below, and do the proper one just when needed
# /p/projects/piam/abrahao/scratch/module_climate_tests/check_infilling.R
logmsg <- paste0(date(), " Started harmonization\n")
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = T)

cmd <- paste0("python ", sfolder, "run_harm_inf.py ", climateAssessmentEmi, " ", climateTempDir, " ", "--no-inputcheck --infilling-database ", infilling_database_file)
system(cmd)

# ================ Running models
logmsg <- paste0(date(), " Started runs\n")
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = T)

cmd <- paste0("python ", sfolder, "run_clim.py ", climateTempDir, "/", basefname, "_harmonized_infilled.csv ", climateTempDir, " --num-cfgs 1 --scenario-batch-size ", 1, " --probabilistic-file ", probabilistic_file)
system(cmd)
# TODO: Replace with this if PR43 of climate-assessment is accepted
# python $sfolder"run_clim.py" $climateTempDir"/"$basefname"_harmonized_infilled.csv" $climateTempDir --num-cfgs 1 --scenario-batch-size 1 --probabilistic-file $probabilistic_file --save-csv-combined-output

# ================ Writing GDX
logmsg <- paste0(date(), " Reading results and writing GDX\n")
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = T)

# Replace with reading the raw CSV if PR43 of climate-assessment is accepted
# This `0000` file is suppposed to be an intermediate file, not final output
cmd <- paste0("Rscript climate_assessment_writegdxs.R ", climateTempDir, "/", basefname, "_harmonized_infilled_IAMC_climateassessment0000.csv")
system(cmd)

logmsg <- paste0(date(), " Finished all\n")
cat(logmsg)
capture.output(cat(logmsg), file = logFile, append = T)


