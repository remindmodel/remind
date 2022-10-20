# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

require(data.table)
require(iamc)
require(rmndt)
library(dplyr)
library(quitte)
library(lucode2)
library(magclass)
library(magpie4)
library(piamInterfaces)
library(stringr) # str_sub, str_split
library(tibble)
library(tidyr)

options(warn = 1)

model <- "REMIND 3.0"                            # modelname in final file
removeFromScen <- ""                           # you can use regex such as: "_diff|_expoLinear"
addToScen <- NULL                              # is added at the beginning

# filenames relative to REMIND main directory (or use absolute path) 
mapping <- NULL                                  # file obtained from piamInterfaces, or AR6/SHAPE/NAVIGATE or NULL to get asked
iiasatemplate <- "yaml_or_xlsx_file_from_IIASA"  # provided for each project, can be yaml or xlsx with a column 'Variable'

# note: you can also pass all these options to output.R, so 'Rscript output.R logFile=mylogfile.txt' works.
lucode2::readArgs("project")

### Load project-specific settings
if (! exists("project")) {
  project <- NULL
} else {
  message("# Overwrite settings with project settings for '", project, "'.")
  if ("NGFS_v3" %in% project) {
    model <- "REMIND-MAgPIE 3.0-4.4"
    mapping <- c("AR6", "AR6_NGFS")
    iiasatemplate <- "../ngfs-internal-workflow/definitions/variable/variables.yaml"
    removeFromScen <- "C_|_bIT|_bit|_bIt"
    filename_prefix <- "NGFS"
  } else if ("ENGAGE_4p5" %in% project) {
    model <- "REMIND 3.0"
    mapping <- c("AR6", "AR6_NGFS")
    iiasatemplate <- "ENGAGE_CD-LINKS_template_2019-08-22.xlsx"
    removeFromScen <- "_diff|_expoLinear"
  } else {
    message("# Command line argument project='", project, "' defined, but not understood.")
  }
}

# overwrite settings with those specified as command-line arguments
lucode2::readArgs("outputdirs", "filename_prefix", "outputFilename", "model",
                  "mapping", "logFile", "removeFromScen", "addToScen", "iiasatemplate")

# variables to be deleted although part of the template
temporarydelete <- NULL # example: c("GDP|MER", "GDP|PPP")

### define filenames

outputFolder <- file.path("output", "export")
if (! dir.exists(outputFolder)) dir.create(outputFolder, recursive = TRUE)
tstamp = format(Sys.time(), "%Y-%m-%d_%H.%M.%S")
if (! exists("filename_prefix")) filename_prefix <- ""
if (! exists("outputdirs")) outputdirs <- dirname(Sys.glob(file.path("output", "*", "fulldata.gdx")))
if (! exists("outputFilename")) {
  outputFilename <- file.path(outputFolder, paste0(c(strsplit(model, " ")[[1]][[1]], filename_prefix, tstamp), collapse = "_"))
} else {
  outputFilename <- gsub("\\.mif$|\\.xlsx$", "", outputFilename)
}
OUTPUT_mif  <- paste0(outputFilename, ".mif")
OUTPUT_xlsx <- paste0(outputFilename, ".xlsx")
if (! exists("logFile")) logFile <- paste0(outputFilename, ".log")

message("### Find various logs in ", logFile)
withCallingHandlers({ # piping messages to logFile

  ### generate mapping if not specified
  if (is.null(mapping) || ! all(file.exists(mapping))) {
    if (all(mapping %in% names(piamInterfaces::templateNames()))) {
      mappingFile <- file.path(outputFolder, paste0(paste0(c("mapping", if (is.null(project)) mapping else project), collapse = "_"), ".csv"))
    } else {
      stop("# mapping = '", paste(mapping, collapse = ","), "' not understood. ",
           "Specify a file or templates such as ", paste0(names(piamInterfaces::templateNames()), collapse = ","))
    }
    message("\n### Generate ", mappingFile, " based on piamInterfaces templates ", paste(mapping, collapse = ","), ".")
    mapreturn <- piamInterfaces::generateMappingfile(templates = mapping, outputDirectory = ".",
                                 fileName = mappingFile, model = model, commentFileName = NULL)
    mapping <- mappingFile
    write(paste0("\n\n\n### Comments from piamInterfaces::generateMappingfile\n\n",
          paste(paste0("- ", mapreturn[["comments"]]$Variable, ": ", mapreturn[["comments"]]$Comment), collapse = "\n"), "\n\n"),
          file = logFile, append = TRUE)
  }

  message("\n### Generating ", OUTPUT_mif, " and .xlsx using mapping ", mapping, ".")

  ### define filenames

  gdxs <- file.path(outputdirs, "fulldata.gdx")
  scenNames <- getScenNames(outputdirs)
  mif_path <- file.path(outputdirs, paste0("REMIND_generic_", scenNames, ".mif"))
  mif_path_polCosts <- file.path(outputdirs, paste0("REMIND_generic_", scenNames, "_adjustedPolicyCosts.mif"))
  mif_path <- ifelse(file.exists(mif_path_polCosts), mif_path_polCosts, mif_path)

  existingfiles <- file.exists(mif_path)
  if (! all(existingfiles)) {
    message("\n### These mif files cannot be found and will be skipped:\n- ",
            paste0(mif_path[! existingfiles], collapse = "\n- "))
    mif_path <- mif_path[existingfiles]
    gdxs <- gdxs[existingfiles]
    scenNames <- scenNames[existingfiles]
  }
  message("\n### These mif files are used:\n- ", paste0(mif_path, collapse = "\n- "))

  filename_remind2_mif <- paste0(outputFilename, "_remind2.mif")

  message("\n### Read mif files...")

  all_mifs <- NULL
  for (mif in mif_path) {
    tmp1 <- read.report(mif, as.list=FALSE)
    # remove -rem-xx and mag-xx from scenario names
    getNames(tmp1, dim = 1) <- gsub("-(rem|mag)-[0-9]{1,2}","",getNames(tmp1, dim=1))
    all_mifs <- mbind(all_mifs, tmp1)
  }

  message("\n### Generate joint mif, remind2 format: ", filename_remind2_mif)

  write.report(all_mifs, file = filename_remind2_mif)

  message("\n### Using mapping, generate joint mif:  ", OUTPUT_mif)

  set_model_and_scenario <- function(mif, model, scen_remove = NULL, scen_add = NULL){
    dt <- readMIF(mif)
    scenario_names <- unique(dt$Scenario)
    dt[, Model := model]
    if (! is.null(scen_remove)) dt[, Scenario := gsub(scen_remove, "", Scenario)]
    if (! is.null(scen_add)) {
      if (all(grepl(scen_add, unique(dt$Scenario), fixed = TRUE))) {
        message(sprintf("Prefix %s already found in all scenario name in %s. Skipping.", scen_add, mif))
      } else {
        dt[, Scenario := paste0(scen_add,Scenario)]
      }
    }
    if (length(unique(dt$Scenario)) < length(scenario_names)) {
      message(length(scenario_names), " scenario names before changes: ", paste(scenario_names, collapse = ", "))
      message(length(unique(dt$Scenario)), " scenario names after changes:  ", paste(unique(dt$Scenario), collapse = ", "))
      stop("Changes to scenario names lead to duplicates. Adapt scen_remove='", scen_remove, "' and scen_add='", scen_add, "'!")
    }
    writeMIF(dt, mif)
  }

  message("# Correct model name to '", model, "'.")
  message("# Adapt scenario names: '",
          addToScen, "' will be prepended, '", removeFromScen, "' will be removed.")
  set_model_and_scenario(filename_remind2_mif, model, removeFromScen, addToScen)

  message("# Apply mapping from ", mapping)

  iamc::write.reportProject(filename_remind2_mif, mapping, OUTPUT_mif, append = FALSE, missing_log = logFile)

  message("# Restore PM2.5 and poverty w.r.t. median income dots in variable names")
  command <- paste("sed -i 's/wrt median income/w\\.r\\.t\\. median income/g;s/PM2\\_5/PM2\\.5/g'", OUTPUT_mif)
  system(command)

  # message("add two trailing spaces for Policy Cost|GDP Loss|w/o transfers (as in DB)")
  # message("make sure that no other variable contains: w/o transfers")
  # command <- paste("sed -i 's/Policy Cost\\|GDP Loss\\|w\/o transfers/Policy Cost\\|GDP Loss\\|w\\/o transfers  /g; s/w\/o transfers/w\\/o transfers  /g'", OUTPUT_mif)
  # system(command)

  message("# Replace N/A for missing years with blanks as recommended by Ed Byers")
  command <- paste("sed -i 's/N\\/A//g'", OUTPUT_mif)
  system(command)

  message("# Remove unwanted timesteps")
  command <- paste("cut -d ';' -f1-21 ", OUTPUT_mif, " > tmp_reporting.tmp")
  system(command)
  command <- paste("mv tmp_reporting.tmp", OUTPUT_mif)
  system(command)

  ## HERE you can change the data again, if required
  mifdata <- read.quitte(OUTPUT_mif, factors = FALSE) %>%
    mutate(model = paste(model)) %>%
    mutate(value = ifelse(!is.finite(value) | is.na(value), 0, value)) %>%
    mutate(scenario = gsub("NA", "", scenario))

  message("# ", length(temporarydelete), " variables are in the list to be temporarily deleted, ",
          length(unique(mifdata$variable[mifdata$variable %in% temporarydelete])), " were deleted.")
  write(paste0("  - ", paste(unique(mifdata$variable[mifdata$variable %in% temporarydelete]), collapse = "\n  - "), "\n\n"),
        file = logFile, append = TRUE)
  mifdata <- filter(mifdata, ! variable %in% temporarydelete)

  if (file.exists(iiasatemplate)) {
    mifdata <- checkIIASASubmission(mifdata, iiasatemplate, logFile)
  } else {
    message("# iiasatemplate ", iiasatemplate , " does not exist, returning full list of variables.")
  }

  # check whether all scenarios have same number of variables
  scenarios <- unique(mifdata$variable)
  for (i in 1:length(scenarios)) {
    stopifnot(length(filter(mifdata, variable %in% scenarios[[1]])) == length(filter(mifdata, variable %in% scenarios[[i]])))
  }

  file.remove(OUTPUT_mif)
  write.mif(mifdata, OUTPUT_mif)

  # perform summation checks
  checkSummationData <- checkSummations(OUTPUT_mif, template = mapping, summationsFile = "AR6",
                                        logFile = logFile, logAppend = TRUE,
                                        dataDumpFile = file.path(outputFolder, "checkSummations.csv"))

  mifdata %>%
    mutate(value = ifelse(!is.finite(value) | paste(value) == "", 0, value)) %>%
    pivot_wider(names_from="period", values_from="value") -> writetoexcel

  writexl::write_xlsx(list("data" = writetoexcel), OUTPUT_xlsx)

  message("\n### mif files: ", sum(existingfiles), " used, ", sum(! existingfiles), " not found, see above.")
  message("\n### Output files written:\n- ", OUTPUT_mif, "\n- ", OUTPUT_xlsx)

}, message = function(x) {
  cat(x$message, file = logFile, append = TRUE)
}) # end of piping message to logfile

message("\n### See details log file: less ", logFile, "\n")
