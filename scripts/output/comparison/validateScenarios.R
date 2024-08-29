# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de


  source("./scripts/start/isSlurmAvailable.R")

  # This script expects a variable `outputdirs` to be defined.
  # Variables `slurmConfig` and `filename_prefix` are used if they defined.
  if (!exists("outputdirs")) {
    stop(
      "Variable outputdirs does not exist. ",
      "Please call validateScenarios.R via output.R, which defines outputdirs.")
  }

  # Start validateScenarios
  startVal <- function(outputDirs, validationConfig) {
    if (!exists("slurmConfig")) {
      slurmConfig <- "--qos=standby"
    }
    jobName <- paste0(
      "valScen",
      "-", nameCore
    )
    outFileName <- jobName
    script <- "scripts/vs/run_validateScenarios.R"
    cat("Starting ", jobName, "\n")
    if (isSlurmAvailable() && ! identical(slurmConfig, "direct")) {
      clcom <- paste0(
        "sbatch ", slurmConfig,
        " --job-name=", jobName,
        " --comment=validateScenarios",
        " --output=", jobName, ".out",
        " --error=", jobName, ".out",
        " --mail-type=END --time=200 --mem-per-cpu=8000",
        " --wrap=\"Rscript ", script,
        " outputDirs=", paste(outputDirs, collapse = ","),
        " validationConfig=", validationConfig,
        "\"")
      cat(clcom, "\n")
      system(clcom)
    } else {
      tmpEnv <- new.env()
      tmpError <- try(sys.source(script, envir = tmpEnv))
      if (!is.null(tmpError))
        warning("Script ", script,
                " was stopped by an error and not executed properly!")
      rm(tmpEnv)
    }
  }

  # choose a config file either from the package or your own
  if (! exists("validationConfig")) {
    availableConfigs <- list.files(
      piamutils::getSystemFile("config/", package = "piamValidation"))
    config <- gms::chooseFromList(availableConfigs,
                                  type = "a validation config",
                                  multiple = FALSE)
    if (config == "") {
      q()
    } else {
      validationConfig <- config
    }
  }

  # Create core of file name / job name.
  timeStamp <- format(Sys.time(), "%Y-%m-%d_%H.%M.%S")
  valName <- gsub(".csv", "", gsub("validationConfig_", "", validationConfig))
  nameCore <- paste0(valName, "-", timeStamp)

  # Start the job
    startVal(
      outputDirs = outputdirs,
      validationConfig = valName)
