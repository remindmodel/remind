# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de




# Header ------------------------------------------------------------------


source("./scripts/start/isSlurmAvailable.R")

# This script expects a variable `outputdirs` to be defined.
# Variables `slurmConfig` and `filename_prefix` are used if they defined.
if (!exists("outputdirs")) {
  stop(
    "Variable outputdirs does not exist. ",
    "Please call compareScenarios.R via output.R, which defines outputdirs.")
}

# Find a suitable default cs2 profile depending on config.RData.
determineDefaultProfiles <- function(outputDir) {
  env <- new.env()
  load(file.path(outputDir, "config.Rdata"), envir = env)
  if (tolower(env$cfg$gms$cm_MAgPIE_coupling) == "on") return("REMIND-MAgPIE")
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
  if (isSlurmAvailable() && ! identical(slurmConfig, "direct")) {
    clcom <- paste0(
      "sbatch ", slurmConfig,
      " --job-name=", jobName,
      " --comment=compareScenarios2",
      " --output=", jobName, ".out",
      " --error=", jobName, ".out",
      " --mail-type=END,FAIL --time=200",
      if (!grepl("--mem", slurmConfig)) " --mem=8000",
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
profiles <- piamPlotComparison::getCs2Profiles()

lucode2::readArgs("profileNames")

# Let user choose cs2 profile(s).
profileNamesDefault <- determineDefaultProfiles(outputdirs[1])

if (! exists("profileNames") || ! all(profileNames %in% names(profiles))) {
  profileNames <- names(profiles)[gms::chooseFromList(
    ifelse(names(profiles) %in% profileNamesDefault, crayon::cyan(names(profiles)), names(profiles)),
    type = "profiles for cs2",
    userinfo = paste0("Leave empty for ", crayon::cyan("cyan"), " default profiles.\n",
                      "For a tutorial, see https://pik-piam.r-universe.dev/articles/remind2/compareScenariosRemind2.html"),
    returnBoolean = TRUE
  )]
}
if (length(profileNames) == 0) {
  profileNames <- profileNamesDefault
  message("Default: ", paste(profileNamesDefault, collapse = ", "), ".\n")
}

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
