# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

#' @title xlsx_IIASA
#' @description Resolves settings (interactively, if needed) for an export of
#' REMIND runs to an IIASA-style xlsx submission, then starts the actual
#' export: either as a slurm job, or directly if slurm is unavailable or
#' --slurmConfig=direct was requested. This mirrors the wrapper/worker split
#' used by scripts/output/comparison/compareScenarios2.R and
#' scripts/output/comparison/validateScenarios.R:
#' - this file only resolves settings and decides local vs. slurm, so it must
#'   stay safe to run interactively on the login node.
#' - scripts/output/export/run_xlsx_IIASA.R does the actual (non-interactive)
#'   work and must be able to run unattended as a plain `Rscript ...` call.

library(lucode2)
library(piamInterfaces)

source("./scripts/start/isSlurmAvailable.R")

# Project catalog -------------------------------------------------------------
# Predefined settings per project. Add your own project here, or leave
# `project` empty below to pick one interactively. Pure data, so it can be
# defined before any packages are loaded.

projects <- list(
  IKEA = list(
    model = "REMIND 3.5",
    mapping = "ScenarioMIP",
    iiasatemplate = "https://files.ece.iiasa.ac.at/common-definitions/common-definitions-template.xlsx",
    checkSummation = "ScenarioMIP"),
  ELEVATE = list(
    mapping = c("NAVIGATE", "ELEVATE"),
    iiasatemplate = "https://files.ece.iiasa.ac.at/elevate/elevate-template.xlsx",
    removeFromScen = "C_|eoc"),
  ELEVATE_coupled = list(
    model = "REMIND-MAgPIE 3.5-4.10",
    mapping = c("NAVIGATE", "NAVIGATE_coupled", "ELEVATE"),
    iiasatemplate = "https://files.ece.iiasa.ac.at/elevate/elevate-template.xlsx",
    removeFromScen = "C_|eoc"),
  ENGAGE_4p5 = list(
    mapping = c("AR6", "AR6_NGFS"),
    iiasatemplate = "ENGAGE_CD-LINKS_template_2019-08-22.xlsx",
    removeFromScen = "_diff|_expoLinear|-all_regi"),
  NGFS = list(
    model = "REMIND-MAgPIE 3.3-4.8",
    mapping = c("AR6", "AR6_NGFS"),
    iiasatemplate = "https://files.ece.iiasa.ac.at/ngfs-phase-5/ngfs-phase-5-template.xlsx",
    removeFromScen = "C_|_bIT|_bit|_bIt|_KLW"),
  NGFS6 = list(
    model = "REMIND-MAgPIE 3.7-4.14",
    mapping = c("ScenarioMIP", "NGFS6"),
    iiasatemplate = "https://files.ece.iiasa.ac.at/ngfs-phase-6/ngfs-phase-6-template.xlsx",
    removeFromScen = "C_|_Pk[0-9]+",
    checkSummation = "ScenarioMIP"),
  RIKEN = list(
    model = "REMIND-MAgPIE 3.4-4.8",
    mapping = c("ScenarioMIP", "MAGICC7_AR6"),
    checkSummation = "ScenarioMIP"),
  ScenarioMIP = list(
    model = "REMIND-MAgPIE 3.5-4.11",
    mapping = "ScenarioMIP",
    iiasatemplate = "https://files.ece.iiasa.ac.at/ssp-submission/ssp-submission-template.xlsx",
    renameScen = c(
      "SMIPv08-H-SSP2-rollBack-def" = "SSP2 - High Emissions",
      "SMIPv08-H-SSP3-rollBack-def" = "SSP3 - High Emissions",
      "SMIPv08-M-SSP1-NPi2025-def" = "SSP1 - Medium Emissions",
      "SMIPv08-M-SSP2-NPi2025-def" = "SSP2 - Medium Emissions",
      "SMIPv08-M-SSP3-NPi2025-def" = "SSP3 - Medium Emissions",
      "SMIPv08-ML-SSP1-EcPrice190-def" = "SSP1 - Medium-Low Emissions",
      "SMIPv08-ML-SSP2-EcPrice300-def" = "SSP2 - Medium-Low Emissions",
      "SMIPv08-ML-SSP3-EcPrice325-def" = "SSP3 - Medium-Low Emissions",
      "SMIPv08-L-SSP1-EcPrice300-def" = "SSP1 - Low Emissions",
      "SMIPv08-L-SSP2-EcPrice400-def" = "SSP2 - Low Emissions",
      "SMIPv08-L-SSP1-EcPrice300-var_yr2035" = "SSP1 - Low Emissions_c",
      "SMIPv08-L-SSP2-EcPrice400-var_yr2035" = "SSP2 - Low Emissions_c",
      "SMIPv08-L-SSP1-EcPrice300-var_yr2050" = "SSP1 - Low Emissions_d",
      "SMIPv08-L-SSP2-EcPrice400-var_yr2050" = "SSP2 - Low Emissions_d",
      "SMIPv08-VLHO-SSP2-EcPrice1300-def" = "SSP2 - Low Overshoot",
      "SMIPv08-VLHO-SSP2-EcPrice1300-var_yr2035" = "SSP2 - Low Overshoot_c",
      "SMIPv08-VLHO-SSP2-EcPrice1300-var_yr2050" = "SSP2 - Low Overshoot_d",
      "SMIPv08-VLLO-SSP1-PkPrice500-def" = "SSP1 - Very Low Emissions",
      "SMIPv08-VLLO-SSP2-PkPrice500-def" = "SSP2 - Very Low Emissions",
      "SMIPv08-VLLO-SSP1-PkPrice500-var_yr2035" = "SSP1 - Very Low Emissions_c",
      "SMIPv08-VLLO-SSP2-PkPrice500-var_yr2035" = "SSP2 - Very Low Emissions_c",
      NULL),
      checkSummation = "ScenarioMIP",
      timesteps = seq(2005, 2100)),
    JustMIP = list(
      model = "REMIND-MAgPIE 3.5-4.10",
      mapping = "ScenarioMIP",
      iiasatemplate = "https://files.ece.iiasa.ac.at/justmip/justmip-template.xlsx",
      removeFromScen = "C_|eoc",
      renameScen = c("Reference_SSP1_800f" = "SSP1_800f", "Reference_SSP2_800f" = "SSP2_800f"),
      checkSummation = "ScenarioMIP",
      timesteps = seq(2005, 2100)),
  PRISMA = list(
    model = "REMIND-MAgPIE 3.4-4.8",
    mapping = c("ScenarioMIP", "PRISMA"),
    iiasatemplate = "https://files.ece.iiasa.ac.at/prisma/prisma-template.xlsx",
    renameScen = c("SMIPv04-M-SSP2-NPi2025-def" = "SSP2 - Medium Emissions", "SMIPv04-L-SSP2-PkBudg1000-def" = "SSP2 - Low Emissions"),
    checkSummation = "NAVIGATE"),
  PRISMA_WP6 = list(
    model = "REMIND-MAgPIE 3.7-4.14",
    mapping = c("ScenarioMIP", "PRISMA"),
    iiasatemplate = "https://files.ece.iiasa.ac.at/prisma/prisma-template.xlsx",
    removeFromScen = "C_",
    renameScen = c(
      "SSP2-MeetAspirations" = "SSP2 - Meet Aspirations",
      "SSP2-AsymmetricRoll-Back" = "SSP2 - Asymmetric Roll-Back",
      "SSP2-LateReawakening" = "SSP2 - Late Reawakening",
      "SSP2-StayingAlive" = "SSP2 - Staying Alive"),
    checkSummation = "ScenarioMIP"),
  NAVIGATE_coupled = list(mapping = c("NAVIGATE", "NAVIGATE_coupled")),
  SHAPE            = list(mapping = c("NAVIGATE", "NAVIGATE_coupled", "SHAPE")),
  TESTTHAT         = list(mapping = "AR6")
)
# EarthCommission uses the ScenarioMIP scenarios with a different mapping and template:
projects$EC <- modifyList(projects$ScenarioMIP, list(
  mapping = c("ScenarioMIP", "EC"),
  iiasatemplate = "https://files.ece.iiasa.ac.at/earthcommission/earthcommission-template.xlsx"))

## Resolve settings: defaults -> project -> command-line args, validating
## everything that can fail before a job is started (see bottom of file).

# Defaults, used if no project below overwrites them
model <- paste("REMIND", paste0(strsplit(gms::readDefaultConfig(".")$model_version, "\\.")[[1]][1:2], collapse = "."))
# model <- "REMIND 3.3"                        # modelname in final file, overwrite if necessary
removeFromScen <- ""                           # you can use regex such as: "_diff|_expoLinear"
renameScen <- NULL                             # c(oldname1 = "newname1", …), without the `C_` and `-rem-[0-9]` stuff
addToScen <- NULL                              # is added at the beginning
timesteps <- c(seq(2005, 2060, 5), seq(2070, 2100, 10))
# filenames relative to REMIND main directory (or use absolute path)
mapping <- NULL                                # file obtained from piamInterfaces, or AR6/SHAPE/NAVIGATE or NULL to get asked
iiasatemplate <- NULL                          # provided for each project, can be yaml or xlsx with a column 'Variable'
checkSummation <- TRUE                         # if TRUE, tries to use the one from mapping. Or specify here

# Pick a project (interactively, or via --project=) and apply its settings
# note: you can also pass all these options to output.R, so 'Rscript output.R --logFile=mylogfile.txt' works.
lucode2::readArgs("project")

# cache once, piamInterfaces::mappingNames() is used several times below and is not free
availableMappings <- names(piamInterfaces::mappingNames())

# add pure mapping from piamInterfaces as additional, minimal "projects"
mappings <- setdiff(availableMappings, c(names(projects), "AR6_NGFS"))
projects <- c(projects,
              do.call(c, lapply(mappings, function(x) stats::setNames(list(list(mapping = x)), x))))

if (! exists("project")) {
  project <- gms::chooseFromList(sort(setdiff(names(projects), "TESTTHAT")), type = "project", multiple = FALSE,
                                 userinfo = paste0("Select project settings or leave empty.\n",
                                                   "You can adjust project settings by editing 'scripts/output/export/xlsx_IIASA.R'"))
}
projectdata <- projects[[project]]
message("# Overwrite settings with project settings for '", project, "'.")
varnames <- c("mapping", "iiasatemplate", "addToScen", "removeFromScen", "renameScen",
              "model", "outputFilename", "logFile", "checkSummation", "timesteps")
for (p in intersect(varnames, names(projectdata))) {
  assign(p, projectdata[[p]])
}

# Command-line arguments take precedence over project settings
lucode2::readArgs("outputdirs", "filename_prefix", "outputFilename", "model", "mapping",
                  "summationFile", "logFile", "removeFromScen", "addToScen", "iiasatemplate", "timesteps")

# Validate settings -- fail here, before a slurm job is started
if (is.null(mapping)) {
  mapping <- gms::chooseFromList(availableMappings, type = "mapping")
}
if (length(mapping) == 0 || ! all(file.exists(mapping) | mapping %in% availableMappings)) {
  stop("mapping='", paste(mapping, collapse = ", "), "' not found.")
}
if (exists("iiasatemplate") && ! is.null(iiasatemplate) && ! file.exists(iiasatemplate) &&
    ! grepl("^https:\\/\\/files\\.ece\\.iiasa\\.ac\\.at\\/.*\\.xlsx$", iiasatemplate)) {
  stop("iiasatemplate=", iiasatemplate, " not found.")
}
if (! is.null(renameScen) && (is.null(names(renameScen)) || any(names(renameScen) == ""))) {
  stop("renameScen must be a named character vector, e.g. c(oldname = \"newname\"), got: ",
       paste(renameScen, collapse = ", "))
}

# Resolve outputdirs and mif file paths to avoid failure in the slurm job
if (! exists("outputdirs")) outputdirs <- dirname(Sys.glob(file.path("output", "*", "fulldata.gdx")))
if (length(outputdirs) == 0 || ! all(file.exists(file.path(outputdirs, "fulldata.gdx")))) {
  stop("No valid outputdirs with fulldata.gdx found: ", paste(outputdirs, collapse = ", "))
}

scenNames <- getScenNames(outputdirs)
mifPathDefault <- file.path(outputdirs, paste0("REMIND_generic_", scenNames, ".mif"))
mifPathPolCosts <- file.path(outputdirs, paste0("REMIND_generic_", scenNames, "_adjustedPolicyCosts.mif"))
mifPath <- ifelse(file.exists(mifPathPolCosts), mifPathPolCosts, mifPathDefault)
existingMif <- file.exists(mifPath)
if (! any(existingMif)) {
  stop("None of the expected mif files exist, cannot proceed:\n- ", paste(mifPath, collapse = "\n- "))
}
if (! all(existingMif)) {
  message("\n### These mif files cannot be found and will be skipped:\n- ", paste0(mifPath[! existingMif], collapse = "\n- "))
  outputdirs <- outputdirs[existingMif]
  scenNames <- scenNames[existingMif]
  mifPath <- mifPath[existingMif]
}
message("\n### These mif files will be used:\n- ", paste0(mifPath, collapse = "\n- "))

# Resolve output filenames
outputFolder <- file.path("output", "export")
if (! dir.exists(outputFolder)) dir.create(outputFolder, recursive = TRUE)
timestamp <- format(Sys.time(), "%Y-%m-%d_%H.%M.%S")
if (! exists("filename_prefix")) filename_prefix <- ""
if (! exists("outputFilename")) {
  outputFilename <- file.path(outputFolder, paste0(c(strsplit(model, " ")[[1]][[1]], filename_prefix, timestamp), collapse = "_"))
} else {
  outputFilename <- gsub("\\.mif$|\\.xlsx$", "", outputFilename)
}
if (! exists("logFile")) logFile <- paste0(outputFilename, ".log")

# variables to be deleted although part of the mapping
temporarydelete <- NULL # example: c("GDP|MER", "GDP|PPP")

## Submit the export job, with settings resolved above, either to slurm or
## directly by running run_xlsx_IIASA.R locally.
startExport <- function(settings, jobName) {
  if (!exists("slurmConfig")) {
    slurmConfig <- "--qos=standby"
  }
  script <- "scripts/output/export/run_xlsx_IIASA.R"
  settingsFile <- paste0(jobName, "_settings.rds")
  saveRDS(settings, settingsFile)
  cat("Starting ", jobName, "\n")
  if (isSlurmAvailable() && ! identical(slurmConfig, "direct")) {
    clcom <- paste0(
      "sbatch ", slurmConfig,
      " --job-name=", jobName,
      " --comment=xlsx_IIASA",
      " --output=", jobName, ".out",
      " --error=", jobName, ".out",
      " --mail-type=END,FAIL --time=200",
      if (!grepl("--mem", slurmConfig)) " --mem=8000",
      # Prefix RSCRIPT_SLURM_HOOK for piam-apptainer integration (empty if unset)
      " --wrap=\"", trimws(paste(Sys.getenv("RSCRIPT_SLURM_HOOK", unset = ""), "Rscript")), " ", script,
      " --settingsFile=", shQuote(settingsFile),
      "\"")
    cat(clcom, "\n")
    system(clcom)
  } else {
    tmpEnv <- new.env()
    tmpEnv$settingsFile <- settingsFile
    tmpError <- try(sys.source(script, envir = tmpEnv))
    if (!is.null(tmpError))
      warning("Script ", script, " was stopped by an error and not executed properly!")
    rm(tmpEnv)
  }
}

startExport(
  settings = list(
    outputdirs = outputdirs,
    scenNames = scenNames,
    mifPath = mifPath,
    outputFolder = outputFolder,
    outputFilename = outputFilename,
    model = model,
    mapping = mapping,
    removeFromScen = removeFromScen,
    addToScen = addToScen,
    renameScen = renameScen,
    checkSummation = checkSummation,
    timesteps = timesteps,
    logFile = logFile,
    iiasatemplate = iiasatemplate,
    temporarydelete = temporarydelete
  ),
  jobName = paste0("xlsxIIASA", ifelse(filename_prefix == "", "", paste0("-", filename_prefix)), "-", timestamp)
)
