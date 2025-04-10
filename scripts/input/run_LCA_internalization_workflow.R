# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
# !/bin/bash

require(quitte)
require(yaml)
require(tidyverse)
require(gdxrrw) # Needs an environmental variable to be set, see below
require(R.utils)

igdx(system("dirname $( which gams )", intern = TRUE))

# This script is meant to run the LCA workflow used to calculate external environmental costs
# meant to be used between REMIND iterations

# 1 create input mappings for the Python code
# 2 set up environment, run python code
# 3 write output to gdx

outputDir <- getwd()
gdxPath <- file.path(outputDir, "fulldata_postsolve.gdx")
cfgPath <- file.path(outputDir, "cfg.txt")
cfg <- read_yaml(cfgPath)

logFile <- file.path(outputDir, paste0("log_lca.txt"))
if (!file.exists(logFile)) {
  file.create(logFile)
  createdLogFile <- TRUE
} else {
  createdLogFile <- FALSE
}


logMsg <- paste0(
  date(), " run_LCA_internalization_workflow.R:\n",
  "outputDir              '", outputDir, "'\n",
  "Using gdxPath          '", gdxPath, "'\n",
  "Using config           '", cfgPath, "'\n",
  if (createdLogFile) "Created logfile        '" else "Append to logFile      '", logFile, "'\n"
 )


logMsg <- paste0(date(), " =================== SET UP LCA scripts environment ===================\n")
capture.output(cat(logMsg), file = logFile, append = TRUE)

#
# BUILD LCA workflow RUN COMMANDS
#

runLCAWorkflowCmd <- paste(
  "python LCA_internalization_workflow.py ",
  "--static",
  "--quantile", cfg$gms$cm_52_LCAquantile,
  "--single_midpoint", cfg$gms$cm_52_single_midpoint,
  "--exclude_midpoints", cfg$gms$cm_52_exclude_midpoints
)


# Get conda environment folder
condaDir <- "/p/projects/rd3mod/python/environments/scm_magicc7"
# Command to activate the conda environment, changes depending on the cluster
if (file.exists("/p/system/modulefiles/defaults/piam/1.25")) {
  condaCmd <- paste0("module load conda/2023.09; source activate ", condaDir, ";")
} else {
  condaCmd <- paste0("module load anaconda/2023.09; source activate ", condaDir, ";")
}


############################# RUNNING MODEL #############################

logMsg <- paste0(
  date(), " =================== RUN LCA workflow ===========================\n",
  runLCAWorkflowCmd, "'\n"
)
capture.output(cat(logMsg), file = logFile, append = TRUE)

system(paste(condaCmd, runLCAWorkflowCmd, "&>>", logFile))

# read in csv, write to gdx
LCAcosts <- read.csv("LCA_costs.csv")

writeToGdx = function(file,df,name){
  df$year = factor(df$year)
  df$region = factor(df$region)
  df$all_te = factor(df$all_te)
  attr(df,which = 'symName') = name
  attr(df,which = 'domains') = c('ttot','all_regi','all_te')
  attr(df,which = 'domInfo') = 'full'
  
  wgdx.lst(file,df,squeeze = F)
}

writeToGdx("LCA_SE", LCAcosts, 'pm_LCAcosts_SE')
print("...done")