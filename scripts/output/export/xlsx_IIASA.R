# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

require(data.table)
require(iamc)
require(rmndt)
library(dplyr, warn.conflicts = FALSE)
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

  if (all(mapping %in% names(templateNames()))) {
    mappingFile <- file.path(outputFolder, paste0(paste0(c("mapping", if (is.null(project)) mapping else project), collapse = "_"), ".csv"))
  } else if (length(mapping) == 1 && file.exists(mapping)) {
    mappingFile <- mapping
  } else {
    message("# Mapping = '", paste(mapping, collapse = ","), " exists neither as file nor mapping name.")
    mapping <- NULL
  }

  message("\n### Generating ", OUTPUT_mif, " and .xlsx.")
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

  message("\n### Read mif files and bind them together...")

  mifdata <- NULL
  for (mif in mif_path) {
    thismifdata <- read.quitte(mif, factors = FALSE)
    # remove -rem-xx and mag-xx from scenario names
    thismifdata$scenario <- gsub("-(rem|mag)-[0-9]{1,2}", "", thismifdata$scenario)
    mifdata <- rbind(mifdata, thismifdata)
  }

  message("# ", length(temporarydelete), " variables are in the list to be temporarily deleted, ",
          length(unique(mifdata$variable[mifdata$variable %in% temporarydelete])), " were deleted.")
  write(paste0("  - ", paste(unique(mifdata$variable[mifdata$variable %in% temporarydelete]), collapse = "\n  - "), "\n\n"),
        file = logFile, append = TRUE)
  mifdata <- filter(mifdata, ! variable %in% temporarydelete)

  message("\n### Generate joint mif, remind2 format: ", filename_remind2_mif)
  write.mif(mifdata, filename_remind2_mif)

  generateIIASASubmission(filename_remind2_mif, mapping = mapping, model = model, mappingFile = mappingFile,
                          removeFromScen = removeFromScen, addToScen = addToScen,
                          outputDirectory = outputFolder, outputPrefix = "",
                          logFile = logFile, generateSingleOutput = TRUE,
                          outputFilename = basename(OUTPUT_mif),
                          iiasatemplate = if (file.exists(iiasatemplate)) iiasatemplate else NULL,
                          generatePlots = TRUE)

}, message = function(x) {
  cat(x$message, file = logFile, append = TRUE)
}) # end of piping message to logfile

message("\n### See details log file: less ", logFile, "\n")
