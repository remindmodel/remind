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

meslog <- function(text, LOGFILE) {
  message(text)
  write(text, file = LOGFILE, append = TRUE)
}

options(warn = 1)

MODEL <- "REMIND 3.0"                            # modelname in final file
REMOVE_FROM_SCEN <- ""                           # you can use regex such as: "_diff|_expoLinear"
ADD_TO_SCEN <- NULL                              # is added at the beginning

# filenames relative to REMIND main directory (or use absolute path) 
MAPPING <- NULL                                  # file obtained from piamInterfaces, or AR6/SHAPE/NAVIGATE or NULL to get asked
iiasatemplate <- "yaml_or_xlsx_file_from_IIASA"  # provided for each project, can be yaml or xlsx with a column 'Variable'

# note: you can also pass all these options to output.R, so 'Rscript output.R LOGFILE=mylogfile.txt' works.
lucode2::readArgs("project")

### Load project-specific settings
if (! exists("project")) {
  project <- NULL
} else {
  message("# Overwrite settings with project settings for '", project, "'.")
  if ("NGFS_v3" %in% project) {
    MODEL <- "REMIND-MAgPIE 3.0-4.4"
    MAPPING <- c("AR6", "AR6_NGFS")
    iiasatemplate <- "../ngfs-internal-workflow/definitions/variable/variables.yaml"
    REMOVE_FROM_SCEN <- "C_|_bIT|_bit|_bIt"
    filename_prefix <- "NGFS"
  } else if ("ENGAGE_4p5" %in% project) {
    MODEL <- "REMIND 3.0"
    MAPPING <- c("AR6", "AR6_NGFS")
    iiasatemplate <- "ENGAGE_CD-LINKS_template_2019-08-22.xlsx"
    REMOVE_FROM_SCEN <- "_diff|_expoLinear"
  } else {
    message("# Command line argument project='", project, "' defined, but not understood.")
  }
}

# overwrite settings with those specified as command-line arguments
lucode2::readArgs("outputdirs", "filename_prefix", "OUTPUT_FILENAME", "MODEL",
                  "MAPPING", "LOGFILE", "REMOVE_FROM_SCEN", "ADD_TO_SCEN", "iiasatemplate")

# variables to be deleted although part of the template
temporarydelete <- NULL # example: c("GDP|MER", "GDP|PPP")

### define filenames

tstamp = format(Sys.time(), "%Y-%m-%d_%H.%M.%S")
if (! exists("filename_prefix")) filename_prefix <- ""
if (! exists("outputdirs")) outputdirs <- dirname(Sys.glob(file.path("output", "*", "fulldata.gdx")))
if (! exists("OUTPUT_FILENAME")) {
  OUTPUT_FILENAME <- file.path("output", paste0(c(strsplit(MODEL, " ")[[1]][[1]], filename_prefix, tstamp), collapse = "_"))
} else {
  OUTPUT_FILENAME <- gsub("\\.mif$|\\.xlsx$", "", OUTPUT_FILENAME)
}
OUTPUT_mif  <- paste0(OUTPUT_FILENAME, ".mif")
OUTPUT_xlsx <- paste0(OUTPUT_FILENAME, ".xlsx")
if (! exists("LOGFILE")) LOGFILE <- paste0(OUTPUT_FILENAME, ".log")

### generate mapping if not specified

if (is.null(MAPPING) || ! all(file.exists(MAPPING))) {
  if (all(MAPPING %in% names(piamInterfaces::templateNames()))) {
    MAPPINGfile <- file.path("output", paste0(paste0(c("mapping", if (is.null(project)) MAPPING else project), collapse = "_"), ".csv"))
  } else {
    stop("# MAPPING = '", paste(MAPPING, collapse = ","), "' not understood. ",
         "Specify a file or templates such as ", paste0(names(piamInterfaces::templateNames()), collapse = ","))
  }
  meslog(paste0("### Generate ", MAPPINGfile, " based on piamInterfaces templates ", paste(MAPPING, collapse = ","), "."), LOGFILE)
  mapreturn <- piamInterfaces::generateMappingfile(templates = MAPPING, outputDirectory = ".",
                               fileName = MAPPINGfile, model = MODEL, commentFileName = NULL)
  MAPPING <- MAPPINGfile
  write(paste0("\n\n\n### Comments from piamInterfaces::generateMappingfile\n\n",
        paste(paste0("- ", mapreturn[["comments"]]$Variable, ": ", mapreturn[["comments"]]$Comment), collapse = "\n"), "\n\n"),
        file = LOGFILE, append = TRUE)
  message("# Find log of piamInterfaces::generateMappingfile() in ", LOGFILE)
}

meslog(paste0("\n### Generating ", OUTPUT_mif, " and .xlsx using mapping ", MAPPING, "."), LOGFILE)
message("# Find log of iamc::write.reportProject() in ", LOGFILE)

### define filenames

gdxs <- file.path(outputdirs, "fulldata.gdx")
scenNames <- getScenNames(outputdirs)
mif_path <- file.path(outputdirs, paste0("REMIND_generic_", scenNames, ".mif"))
mif_path_polCosts <- file.path(outputdirs, paste0("REMIND_generic_", scenNames, "_adjustedPolicyCosts.mif"))
mif_path <- ifelse(file.exists(mif_path_polCosts), mif_path_polCosts, mif_path)

existingfiles <- file.exists(mif_path)
if (! all(existingfiles)) {
  meslog(paste0("\n### These mif files cannot be found and will be skipped:\n- ",
          paste0(mif_path[! existingfiles], collapse = "\n- ")), LOGFILE)
  mif_path <- mif_path[existingfiles]
  gdxs <- gdxs[existingfiles]
  scenNames <- scenNames[existingfiles]
}
meslog(paste0("\n### These mif files are used:\n- ", paste0(mif_path, collapse = "\n- ")), LOGFILE)

filename_remind2_mif <- paste0(OUTPUT_FILENAME, "_remind2.mif")

meslog("\n### Read mif files...", LOGFILE)

all_mifs <- NULL
for (mif in mif_path) {
  tmp1 <- read.report(mif, as.list=FALSE)
  # remove -rem-xx and mag-xx from scenario names
  getNames(tmp1, dim = 1) <- gsub("-(rem|mag)-[0-9]{1,2}","",getNames(tmp1, dim=1))
  all_mifs <- mbind(all_mifs, tmp1)
}

meslog(paste0("\n### Generate joint mif, remind2 format: ", filename_remind2_mif), LOGFILE)

write.report(all_mifs, file = filename_remind2_mif)

meslog(paste0("\n### Using mapping, generate joint mif:  ", OUTPUT_mif), LOGFILE)

set_model_and_scenario <- function(mif, model, scen_remove = NULL, scen_add = NULL){
  dt <- readMIF(mif)
  scenario_names <- unique(dt$Scenario)
  dt[, Model := model]
  if (!is.null(scen_remove)) dt[, Scenario := gsub(scen_remove,"",Scenario)]
  if (!is.null(scen_add)) {
    if (grepl(scen_add, unique(dt$Scenario), fixed = TRUE)){
      meslog(sprintf("Prefix %s already found in scenario name in %s.", scen_add, mif), LOGFILE)
    } else {
      dt[, Scenario := paste0(scen_add,Scenario)]
    }
  }
  if (length(unique(dt$Scenario)) < length(scenario_names)) {
    meslog(paste0(length(scenario_names), " scenario names before changes: ", paste(scenario_names, collapse = ", ")), LOGFILE)
    meslog(paste0(length(unique(dt$Scenario)), " scenario names after changes:  ", paste(unique(dt$Scenario), collapse = ", ")), LOGFILE)
    stop("Changes to scenario names lead to duplicates. Adapt scen_remove='", scen_remove, "' and scen_add='", scen_add, "'!")
  }
  writeMIF(dt, mif)
}

meslog(paste0("# Correct model name to '", MODEL, "'"), LOGFILE)
meslog(paste0("# Adapt scenario names: '",
        ADD_TO_SCEN, "' will be prepended, '", REMOVE_FROM_SCEN, "' will be removed."), LOGFILE)
set_model_and_scenario(filename_remind2_mif, MODEL, REMOVE_FROM_SCEN, ADD_TO_SCEN)

meslog(paste0("# Apply mapping from ", MAPPING), LOGFILE)

iamc::write.reportProject(filename_remind2_mif, MAPPING, OUTPUT_mif, append = FALSE, missing_log = LOGFILE)

meslog("# Restore PM2.5 and poverty w.r.t. median income dots in variable names", LOGFILE)
command <- paste("sed -i 's/wrt median income/w\\.r\\.t\\. median income/g;s/PM2\\_5/PM2\\.5/g'", OUTPUT_mif)
system(command)

# message("add two trailing spaces for Policy Cost|GDP Loss|w/o transfers (as in DB)")
# message("make sure that no other variable contains: w/o transfers")
# command <- paste("sed -i 's/Policy Cost\\|GDP Loss\\|w\/o transfers/Policy Cost\\|GDP Loss\\|w\\/o transfers  /g; s/w\/o transfers/w\\/o transfers  /g'", OUTPUT_mif)
# system(command)

meslog("# Replace N/A for missing years with blanks as recommended by Ed Byers", LOGFILE)
command <- paste("sed -i 's/N\\/A//g'", OUTPUT_mif)
system(command)

meslog("# Remove unwanted timesteps", LOGFILE)
command <- paste("cut -d ';' -f1-21 ", OUTPUT_mif, " > tmp_reporting.tmp")
system(command)
command <- paste("mv tmp_reporting.tmp", OUTPUT_mif)
system(command)

## HERE you can change the data again, if required
mifdata <- read.quitte(OUTPUT_mif, factors = FALSE) %>%
  mutate(model = paste(MODEL)) %>%
  mutate(value = ifelse(!is.finite(value) | is.na(value), 0, value)) %>%
  mutate(scenario = gsub("NA", "", scenario))

meslog(paste0("# ", length(temporarydelete), " variables are in the list to be temporarily deleted, ",
        length(unique(mifdata$variable[mifdata$variable %in% temporarydelete])), " were deleted."), LOGFILE)
write(paste0("  - ", paste(unique(mifdata$variable[mifdata$variable %in% temporarydelete]), collapse = "\n  - "), "\n\n"),
      file = LOGFILE, append = TRUE)
mifdata <- filter(mifdata, ! variable %in% temporarydelete)

if (file.exists(iiasatemplate)) {
  mifdata <- checkIIASASubmission(mifdata, iiasatemplate, LOGFILE)
} else {
  meslog(paste0("# iiasatemplate ", iiasatemplate , " does not exist, returning full list of variables."), logfile)
}

# check whether all scenarios have same number of variables
scenarios <- unique(mifdata$variable)
for (i in 1:length(scenarios)) {
  stopifnot(length(filter(mifdata, variable %in% scenarios[[1]])) == length(filter(mifdata, variable %in% scenarios[[i]])))
}

file.remove(OUTPUT_mif)
write.mif(mifdata, OUTPUT_mif)

# filter(scenario == "d_delfrag") %>%

mifdata %>%
  mutate(value = ifelse(!is.finite(value) | paste(value) == "", 0, value)) %>%
  pivot_wider(names_from="period", values_from="value") -> writetoexcel

writexl::write_xlsx(list("data" = writetoexcel), OUTPUT_xlsx)

meslog(paste0("\n### mif files: ", sum(existingfiles), " used, ", sum(! existingfiles), " not found, see above."), LOGFILE)
meslog(paste0("\n### Output files written:\n- ", OUTPUT_mif, "\n- ", OUTPUT_xlsx), LOGFILE)
message("\n### See log file: less ", LOGFILE, "\n")
