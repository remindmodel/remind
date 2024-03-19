# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
#!/bin/bash

# This script is meant to run the full IIASA climate assessment using a single parameter set,
# meant to be used between REMIND iterations

CLIMATE_ASSESSMENT_FILES_DIR <- "/p/projects/rd3mod/climate-assessment-files/"
workfolder <- "climate-temp"
logfile="climate.log"
probabilistic_file <- paste0(CLIMATE_ASSESSMENT_FILES_DIR,"/parsets/RCP20_50.json")
gdxfname <- "fulldata_prepostsolve.gdx"

sfolder="/p/projects/piam/abrahao/scratch/iiasa/climate-assessment/scripts/" #TODO: Get the one used in the renv


infilling_database_file=paste0(CLIMATE_ASSESSMENT_FILES_DIR,"/1652361598937-ar6_emissions_vetted_infillerdatabase_10.5281-zenodo.6390768.csv")

# Set relevant environment variables and create a MAGICC worker directory
Sys.setenv(MAGICC_EXECUTABLE_7=paste0(CLIMATE_ASSESSMENT_FILES_DIR,"/magicc-v7.5.3/bin/magicc"))
Sys.setenv(MAGICC_WORKER_ROOT_DIR=normalizePath(paste0(workfolder,"/workers/"))) # Has to be an absolute path
dir.create(Sys.getenv("MAGICC_WORKER_ROOT_DIR"), recursive = T, showWarnings = F)
Sys.setenv(MAGICC_WORKER_NUMBER=1) # TODO: Get this from slurm or nproc

inemifname <- paste0(workfolder,"/emimif_ar6.csv")
basefname <- sub("\\.csv$","",basename(inemifname))

# Set up a log
logmsg <- paste0(date(), " Created log\n================================ EXECUTING climate_assessment_run.R =================================\n")
cat(logmsg)
capture.output(cat(logmsg), file = logfile, append = F)


# ================  Run postprocessing on GDX
logmsg <- paste0(date(), " Started postprocessing\n")
cat(logmsg)
capture.output(cat(logmsg), file = logfile, append = T)

cmd <- paste0("Rscript climate_assessment_prepare.R ", gdxfname," cfg.txt ",workfolder)
system(cmd)


# ================  Harmonization and infilling step
# TODO: This can take up to a minute, and shouldn't change much between
# REMIND iterations. Lets try to replace this step in most iterations with
# the simple scaling method in the script below, and do the proper one just when needed
# /p/projects/piam/abrahao/scratch/module_climate_tests/check_infilling.R
logmsg <- paste0(date(), " Started harmonization\n")
cat(logmsg)
capture.output(cat(logmsg), file = logfile, append = T)

cmd <- paste0("python ", sfolder, "run_harm_inf.py ", inemifname, " ", workfolder, " ", "--no-inputcheck --infilling-database ", infilling_database_file)
system(cmd)

# ================ Running models
logmsg <- paste0(date(), " Started runs\n")
cat(logmsg)
capture.output(cat(logmsg), file = logfile, append = T)

cmd <- paste0("python ", sfolder, "run_clim.py ", workfolder, "/", basefname, "_harmonized_infilled.csv ", workfolder, " --num-cfgs 1 --scenario-batch-size ", 1, " --probabilistic-file ", probabilistic_file)
system(cmd)
# TODO: Replace with this if PR43 of climate-assessment is accepted
# python $sfolder"run_clim.py" $workfolder"/"$basefname"_harmonized_infilled.csv" $workfolder --num-cfgs 1 --scenario-batch-size 1 --probabilistic-file $probabilistic_file --save-csv-combined-output

# ================ Writing GDX
logmsg <- paste0(date(), " Reading results and writing GDX\n")
cat(logmsg)
capture.output(cat(logmsg), file = logfile, append = T)

# Replace with reading the raw CSV if PR43 of climate-assessment is accepted
# This `0000` file is suppposed to be an intermediate file, not final output
cmd <- paste0("Rscript climate_assessment_writegdxs.R ", workfolder, "/", basefname, "_harmonized_infilled_IAMC_climateassessment0000.csv")
system(cmd)

logmsg <- paste0(date(), " Finished all\n")
cat(logmsg)
capture.output(cat(logmsg), file = logfile, append = T)


