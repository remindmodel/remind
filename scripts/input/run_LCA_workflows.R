# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
# !/bin/bash

library(quitte)
library(yaml)
library(tidyverse)
library(gdxrrw) # Needs an environmental variable to be set, see below
library(R.utils)
library(remind2)
library(lucode2)
library(data.table)
library(gdxdt)

igdx(system("dirname $( which gams )", intern = TRUE))

# This script is meant to run the LCA workflow used to calculate external environmental costs
# meant to be used between REMIND iterations

# 1 create input mappings for the Python code
# 2 set up environment, run python code
# 3 write output to gdx

args <- commandArgs(trailingOnly = TRUE)

outputDir <- getwd()
gdxPath <- file.path(outputDir, args[1])
scenario <- lucode2::getScenNames(outputDir)
mifName <- paste0("REMIND_generic_", scenario, ".mif")

load("config.Rdata")

logFile <- file.path(outputDir, paste0("log_lca.txt"))
if (!file.exists(logFile)) {
  file.create(logFile)
  createdLogFile <- TRUE
} else {
  createdLogFile <- FALSE
}

errFile <- file.path(outputDir, paste0("err_lca.txt"))
if (!file.exists(errFile)) {
  file.create(errFile)
}


logMsg <- paste0(
  date(), " run_LCA_internalization_workflow.R:\n",
  "outputDir                 '", outputDir, "'\n",
  "Using gdxPath             '", gdxPath, "'\n",
  "Stage/iteration type      '", args[2], "'\n",
  if (createdLogFile) "Created logfile        '" else "Append to logFile      '", logFile, "'\n", "\n"
 )
capture.output(cat(logMsg), file = logFile, append = TRUE)

#
# RUN REMIND REPORTING OR COPY EXISTING MIF FILE
#

logMsg <- paste0(date(), " =================== Copy or create REMIND reporting ===================\n")
capture.output(cat(logMsg), file = logFile, append = TRUE)

newName <- paste0("remind_", scenario, ".mif")
mifPath <- file.path(outputDir, "lca", "remind_runs", newName)

if (args[2] == "preloop") {
  # create "lca" subdirectory
  dir.create("lca")
  dir.create("lca/remind_runs")

  inputMifDir <- file.path(cfg$remind_folder, dirname(cfg$files2export$start[["input.gdx"]]))

  inputScen <- lucode2::getScenNames(inputMifDir)
  inputMifName <- paste0("REMIND_generic_", inputScen, ".mif")
  inputMifPath <- file.path(inputMifDir, inputMifName)
  file.copy(from=inputMifPath, to=mifPath)

  logMsg <- paste0("Preloop mode: .mif file copied from ", inputMifDir, "\n", "\n")
  capture.output(cat(logMsg), file = logFile, append = TRUE)

  # which routines to run
  routines <- "--plca --calcCosts --aggTaxes"
} else if (args[2] == "update_plca") {
  t0 <- Sys.time()
  runReportingCmd <- paste(
    "Rscript reporting.R",
    paste0("gdx_name=", args[1]),
    paste0("outputdir=", outputDir)
  )
  system(paste(runReportingCmd, "&>>", logFile))
  t1 <- Sys.time()
  dt <- paste0(round(as.numeric(difftime(time1 = b, time2 = a, units = "secs")), 3), " seconds")

  oldName <- paste0("REMIND_generic_", scenario, ".mif")
  
  file.copy(from=oldName, to=mifPath)

  logMsg <- paste0(args[2]," mode: Reporting ", newName, " done in ", dt, "\n", "\n")
  capture.output(cat(logMsg), file = logFile, append = TRUE)

  # which routines to run
  routines <- "--plca --calcCosts --aggTaxes"
} else if (args[2] == "recalculate_taxes") {
  t0 <- Sys.time()
  runReportingCmd <- paste(
    "Rscript reporting.R",
    paste0("gdx_name=", args[1]),
    paste0("outputdir=", outputDir)
  )
  system(paste(runReportingCmd, "&>>", logFile))
  t1 <- Sys.time()
  dt <- paste0(round(as.numeric(difftime(time1 = b, time2 = a, units = "secs")), 3), " seconds")

  oldName <- paste0("REMIND_generic_", scenario, ".mif")
  
  file.copy(from=oldName, to=mifPath)

  logMsg <- paste0(args[2]," mode: Reporting ", newName, " done in ", dt, "\n", "\n")
  capture.output(cat(logMsg), file = logFile, append = TRUE)

  # which routines to run
  routines <- "--aggTaxes"
}


#
# SET UP CONDA ENVIRONMENT
#

# Get conda environment folder
# condaDir <- "/p/projects/rd3mod/python/environments/scm_magicc7"
condaDir <- "internalizer"
# Command to activate the conda environment, changes depending on the cluster
if (file.exists("/p/system/modulefiles/defaults/piam/1.25")) {
  condaCmd <- paste0("module load conda; source activate ", condaDir, ";")
} else {
  condaCmd <- paste0("module load anaconda; source activate ", condaDir, ";")
}

# system(paste(condaCmd, "&>>", logFile))

#
# RUN LCA WORKFLOW
#

runLCAWorkflowCmd <- paste(
  "python LCA_workflows.py ",
  mifPath,
  gdxPath,
  scenario,
  "--aggTaxes",
  routines,
  paste0("--", cfg$gms$c_52_monetization_type), cfg$gms$c_52_LCA_monetizationFactor,
  "--single_midpoint", paste0("'", cfg$gms$cm_52_single_midpoint, "'"),
  "--exclude_midpoints", paste0("'", cfg$gms$cm_52_exclude_midpoints, "'")
)

logMsg <- paste0(
  date(), " =================== RUN LCA workflow ===========================\n"
)
capture.output(cat(logMsg), file = logFile, append = TRUE)

system(paste(condaCmd, runLCAWorkflowCmd, "&>>", errFile))

# 
# WRITE GDXes
#

SEcosts <- as.data.table(read.csv("lca/lca_costs_SE.csv"))
gdxdt::writegdx.parameter(
  "LCA_SE.gdx",
  SEcosts,
  name = "pm_LCAcosts_SE",
  valcol = "cost",
  uelcols = c('ttot', 'all_regi', 'all_te')
)

FEcosts <- as.data.table(read.csv("lca/lca_costs_FE.csv"))
gdxdt::writegdx.parameter(
  "LCA_FE.gdx",
  FEcosts,
  name = "pm_LCAcosts_FE",
  valcol = "cost",
  uelcols = c('ttot', 'all_regi', 'emi_sectors', 'all_enty')
)

print("...done")