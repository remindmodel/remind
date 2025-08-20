library(quitte)
library(yaml)
library(tidyverse)
library(R.utils)
library(remind2)
library(lucode2)

if (!exists("source_include")) {
  # Define arguments that can be read from command line
  outputdir <- "."
  lucode2::readArgs("outputdir")
}

load(file.path(outputdir, "config.Rdata"))

dir.create(file.path(outputdir, "lca/reporting"))

# Get conda environment folder
# condaDir <- "/p/projects/rd3mod/python/environments/scm_magicc7"
condaDir <- "internalizer"
# Command to activate the conda environment, changes depending on the cluster
if (file.exists("/p/system/modulefiles/defaults/piam/1.25")) {
  condaCmd <- paste0("module load conda; source activate ", condaDir, ";")
} else {
  condaCmd <- paste0("module load anaconda; source activate ", condaDir, ";")
}

runLCAWorkflowCmd <- paste(
  "python /p/tmp/davidba/internalization_develop/analysis/run_LCA_reporting_v2.py ",
  outputdir,
  paste0("--", cfg$gms$c_52_monetization_type), cfg$gms$c_52_LCA_monetizationFactor
)


system(paste(condaCmd, runLCAWorkflowCmd))