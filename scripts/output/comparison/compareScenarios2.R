# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de




# Header ------------------------------------------------------------------


source("./scripts/utils/isSlurmAvailable.R")

# This script expects a variable `outputdirs` to be defined.
# Variables `slurmConfig` and `filename_prefix` are used if they defined.
if (!exists("outputdirs")) {
  stop(
    "Variable outputdirs does not exist. ",
    "Please call comapreScenarios.R via output.R, which defines outputdirs.")
}




# Function Definitions ----------------------------------------------------


# Ask user to select an element form a sequence.
chooseFromSequence <- function(sequence, title, default) {
  cat(
    "\n\n", title,
    paste0(
      "Leave empty for ",
      crayon::cyan("cyan"),
      " (", paste(default, collapse = ", "), ")."),
    "\n",
    sep = "\n")
  numList <- paste(seq_along(sequence), sequence, sep = ": ")

  cat(ifelse(sequence %in% default, crayon::cyan(numList), numList), sep = "\n")
  cat("\nNumbers, e.g., '1', '2,4', '3:5':\n")
  input <- gms::getLine()
  ids <- as.numeric(eval(parse(text = paste("c(", input, ")"))))
  if (any(!ids %in% seq_along(sequence))) {
    stop("Choose numbers between 1 and ", length(sequence))
  }
  chosenElements <- if (length(ids) == 0) default else sequence[ids]
  cat("\nchosen elements:\n  ", paste(chosenElements, collapse = "\n  "), "\n\n", sep = "")
  return(chosenElements)
}


# Find a suitable default cs2 profile depending on config.RData.
determineDefaultProfiles <- function(outputDir) {
  env <- new.env()
  load(file.path(outputDir, "config.Rdata"), envir = env)
  if (env$cfg$gms$cm_MAgPIE_coupling) return("REMIND-MAgPIE")
  regionMappingFile <- basename(env$cfg$regionmapping)
  defaults <- switch(
    regionMappingFile,
    "default",
    "regionmappingH12.csv" =  c("H12", "H12-short"),
    "regionmapping_21_EU11.csv" =  c("H12", "H12-short", "EU27", "EU27-short", "AriadneDEU"))
  return(defaults)
}


# Start compareScenarios2 either on the cluster or locally.
startComp <- function(
  outputDirs,
  nameCore,
  profileName
) {
  if (!exists("slurmConfig")) {
    slurmConfig <- "--qos=standby"
  }
  jobName <- paste0(
      "compScen",
      "-", nameCore,
      "-", profileName
    )
  outFileName <- jobName
  script <- "scripts/cs2/run_compareScenarios2.R"
  cat("Starting ", jobName, "\n")
  if (isSlurmAvailable()) {
    clcom <- paste0(
      "sbatch ", slurmConfig,
      " --job-name=", jobName,
      " --output=", jobName, ".out",
      " --error=", jobName, ".out",
      " --mail-type=END --time=200 --mem-per-cpu=8000",
      " --wrap=\"Rscript ", script,
      " outputDirs=", paste(outputDirs, collapse = ","),
      " profileName=", profileName,
      " outFileName=", outFileName,
      "\"")
    cat(clcom, "\n")
    system(clcom)
  } else {
    tmpEnv <- new.env()
    tmpError <- try(sys.source(script, envir = tmpEnv))
    if (!is.null(tmpError))
      warning("Script ", script, " was stopped by an error and not executed properly!")
    rm(tmpEnv)
  }
}



# Code --------------------------------------------------------------------


# Load cs2 profiles.
profiles <- remind2::getCs2Profiles()

# Let user choose cs2 profile(s).
profileNamesDefault <- determineDefaultProfiles(outputdirs[1])
profileNames <- chooseFromSequence(
  names(profiles),
  "Choose profiles for cs2.",
  profileNamesDefault)

# Create core of file name / job name.
timeStamp <- format(Sys.time(), "%Y-%m-%d_%H.%M.%S")
if (!exists("filename_prefix")) filename_prefix <- ""
nameCore <- paste0(filename_prefix, ifelse(filename_prefix == "", "", "-"), timeStamp)

# Start a job for each profile.
for (profileName in profileNames) {
  startComp(
    outputDirs = outputdirs,
    nameCore = nameCore,
    profileName = profileName)
}
