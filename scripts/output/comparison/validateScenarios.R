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
  startVal <- function(outputDirs, validationConfig, validationReportName) {
    if (!exists("slurmConfig")) {
      slurmConfig <- "--qos=standby"
    }
    jobName <- paste0(
      "valScen",
      "-", nameCore
    )
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
        " --outputdirs=", shQuote(paste(outputDirs, collapse = ",")),
        " --validationConfig=", shQuote(validationConfig),
        " --validationReportName=", shQuote(validationReportName),
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

  # let the user pick an entry from the package or provide an own file
  chooseFromPackageOrFile <- function(available, type, fileHint, userinfo = NULL) {
    ownFile <- paste0("enter path to own file (", fileHint, ")")
    choice <- gms::chooseFromList(c(available, ownFile),
                                  type = type,
                                  userinfo = userinfo,
                                  multiple = FALSE)
    if (length(choice) == 0) return("")
    if (identical(choice, ownFile)) {
      message("Path to own file (", fileHint, "):")
      choice <- normalizePath(gms::getLine(), mustWork = FALSE)
      if (!file.exists(choice)) stop("File not found: ", choice)
    }
    choice
  }

  # choose a config from the package or an own file
  if (! exists("validationConfig")) {
    validationConfig <- chooseFromPackageOrFile(
      piamValidation::listConfigs(),
      type = "a validation config",
      fileHint = ".csv/.xlsx",
      userinfo = "Leave empty to abort.")
    if (validationConfig == "") {
      q()
    }
  }
  # strip prefix/suffix in case validationConfig was predefined as file name
  if (!file.exists(validationConfig)) {
    validationConfig <- gsub("\\.csv$", "",
                             gsub("^validationConfig_", "", validationConfig))
  }

  # choose a report template from the package or an own file
  if (! exists("validationReportName")) {
    validationReportName <- chooseFromPackageOrFile(
      piamValidation::listReports(),
      type = "a validation report template",
      fileHint = ".Rmd",
      userinfo = "Leave empty for the default report.")
    if (validationReportName == "") {
      validationReportName <- "default"
      message("Default: default report template.\n")
    }
  }

  # Create core of file name / job name, "custom" for user-provided files.
  timeStamp <- format(Sys.time(), "%Y-%m-%d_%H.%M.%S")
  if (!exists("filename_prefix")) filename_prefix <- ""
  valName <- if (file.exists(validationConfig)) "custom" else validationConfig
  repInfix <- if (identical(validationReportName, "default")) "" else paste0(
    "-", if (file.exists(validationReportName)) "custom" else validationReportName)
  nameCore <- paste0(filename_prefix, ifelse(filename_prefix == "", "", "-"),
                     valName, repInfix, "-", timeStamp)

  # Start the job
    startVal(
      outputDirs = outputdirs,
      validationConfig = validationConfig,
      validationReportName = validationReportName)