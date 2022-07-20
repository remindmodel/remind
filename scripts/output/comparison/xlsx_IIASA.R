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
library(tidyr)
library(quitte)
library(readxl)
library(yaml)
library(magclass)
library(lucode2)
library(magpie4)
library(stringr) # str_sub

options(warn = 1)

MODEL <- "REMIND-MAgPIE 3.0-4.4"                            # modelname in final file
REMOVE_FROM_SCEN <- ""                                      # you can use regex such as: "_diff|_expoLinear"
ADD_TO_SCEN <- NULL                                         # is added at the beginning

# filenames relative to REMIND main directory (or use absolute path) 
MAPPING <- "mapping_r30m44_AR6NGFS.csv"                     # obtained by generate_mappingfile.R in project_interfaces
iiasatemplate <- "ENGAGE_CD-LINKS_template_2019-08-22.xlsx" # provided for each project, can be yaml or xlsx with a column 'Variable'

# note: you can also pass all these options to output.R, so 'Rscript output.R LOGFILE=mylogfile.txt' works.
lucode2::readArgs("outputdirs", "filename_prefix", "OUTPUT_FILENAME", "MODEL", "MAPPING", "LOGFILE", "REMOVE_FROM_SCEN", "ADD_TO_SCEN", "iiasatemplate")

tstamp = format(Sys.time(), "%Y-%m-%d_%H.%M.%S")
if (! exists("filename_prefix")) filename_prefix <- ""
if (! exists("outputdirs")) outputdirs <- dirname(Sys.glob(file.path("output", "*", "fulldata.gdx")))
if (! exists("OUTPUT_FILENAME")) {
  OUTPUT_FILENAME <- paste0(strsplit(MODEL, " ")[[1]][[1]], "_", filename_prefix, "_", tstamp)
} else {
  OUTPUT_FILENAME <- gsub("\\.mif$|\\.xlsx$", "", OUTPUT_FILENAME)
}
OUTPUT_mif  <- paste0(OUTPUT_FILENAME, ".mif")
OUTPUT_xlsx <- paste0(OUTPUT_FILENAME, ".xlsx")
if (! exists("LOGFILE")) LOGFILE <- paste0(OUTPUT_FILENAME, ".log")

logtext <- paste0("### Generating ", OUTPUT_mif, " and .xlsx for model ", MODEL, " using mapping ", MAPPING, ".")
message(logtext)
write(paste0("\n\n", logtext), file = LOGFILE, append = TRUE)
message("# Requested changes to scenario names: '", ADD_TO_SCEN, "' will be prepended, '", REMOVE_FROM_SCEN, "' will be removed.")
message("# Find log of iamc::write.reportProject() in ", LOGFILE)

### further features

# variables to be deleted although part of the template
temporarydelete <- NULL # c("Price|Agriculture|Corn|Index", "Price|Agriculture|Non-Energy Crops and Livestock|Index", "Price|Agriculture|Non-Energy Crops|Index", "Price|Agriculture|Soybean|Index", "Price|Agriculture|Wheat|Index")



### define filenames

gdxs <- file.path(outputdirs, "fulldata.gdx")
scenNames <- getScenNames(outputdirs)
mif_path <- file.path(outputdirs, paste("REMIND_generic_", scenNames, ".mif", sep = ""))
mif_path_polCosts <- file.path(outputdirs, paste("REMIND_generic_", scenNames, "_adjustedPolicyCosts.mif", sep = ""))
mif_path <- ifelse(file.exists(mif_path_polCosts), mif_path_polCosts, mif_path)

existingfiles <- file.exists(mif_path)
if (! all(existingfiles)) {
  message("\n### These mif files cannot be found and will be skipped:\n- ", paste0(mif_path[! existingfiles], collapse = "\n- "))
  mif_path <- mif_path[existingfiles]
  gdxs <- gdxs[existingfiles]
  scenNames <- scenNames[existingfiles]
}
message("\n### These mif files are used:\n- ", paste0(mif_path, collapse = "\n- "))

if (! file.exists(MAPPING)) {
  stop("Mapping file ", MAPPING, " not found.")
}
filename_remind2_mif <- paste0(OUTPUT_FILENAME, "_remind2.mif")

message("\n### Read mif files...")

all_mifs <- NULL
for (mif in mif_path) {
  tmp1 <- read.report(mif, as.list=FALSE)
  getNames(tmp1, dim = 1) <- gsub("-(rem|mag)-[0-9]{1,2}","",getNames(tmp1, dim=1)) # remove -rem-xx and mag-xx from scenario names
  all_mifs <- mbind(all_mifs, tmp1)
}

message("\n### Generate joint mif, remind2 format: ", filename_remind2_mif)

write.report(all_mifs, file = filename_remind2_mif)

message("\n### Generate joint mif using mapping:   ", OUTPUT_mif)


set_model_and_scenario <- function(mif, model, scen_remove = NULL, scen_add = NULL){
  dt <- readMIF(mif)
  scenario_names <- unique(dt$Scenario)
  dt[, Model := model]
  if (!is.null(scen_remove)) dt[, Scenario := gsub(scen_remove,"",Scenario)]
  if (!is.null(scen_add)) {
    if (grepl(scen_add, unique(dt$Scenario), fixed = TRUE)){
      message(sprintf("Prefix %s already found in scenario name in %s.", scen_add, mif))
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

message("# correct model and scenario names")
set_model_and_scenario(filename_remind2_mif, MODEL, REMOVE_FROM_SCEN, ADD_TO_SCEN)

message("# apply mapping from ", MAPPING)
iamc::write.reportProject(filename_remind2_mif, MAPPING, OUTPUT_mif, append = FALSE, missing_log = LOGFILE)

message("# restoring PM2.5 and poverty w.r.t. median income dots in variable names")
command <- paste("sed -i 's/wrt median income/w\\.r\\.t\\. median income/g;s/PM2\\_5/PM2\\.5/g'", OUTPUT_mif)
system(command)

# message("add two trailing spaces for Policy Cost|GDP Loss|w/o transfers (as in DB)")
# message("make sure that no other variable contains: w/o transfers")
# command <- paste("sed -i 's/Policy Cost\\|GDP Loss\\|w\/o transfers/Policy Cost\\|GDP Loss\\|w\\/o transfers  /g; s/w\/o transfers/w\\/o transfers  /g'", OUTPUT_mif)
# system(command)

message("# replacing N/A for missing years with blanks as recommended by Ed Byers")
command <- paste("sed -i 's/N\\/A//g'", OUTPUT_mif)
system(command)

message("# remove unwanted timesteps")
command <- paste("cut -d ';' -f1-21 ", OUTPUT_mif, " > tmp_reporting.tmp")
system(command)
command <- paste("mv tmp_reporting.tmp", OUTPUT_mif)
system(command)

## HERE you can change the data again, if required
data <- read.quitte(OUTPUT_mif, factors = FALSE) %>%
  mutate(model = paste(MODEL))

message("# correct units")
data$unit[data$unit == "bn m2/yr"] <- "billion m2/yr"
data$unit[data$unit == "bn vkm/yr"] <- "billion vkm/yr"
data$unit[data$unit == "bn tkm/yr"] <- "billion tkm/yr"
data$unit[data$unit == "bn pkm/yr"] <- "billion pkm/yr"
data$unit[data$unit == "Mt/year"] <- "Mt/yr"
data$unit[data$unit == "kt CF4-equiv/yr"] <- "kt CF4/yr"

message("# load IIASA template file ", iiasatemplate)

if (! file.exists(iiasatemplate)) {
  stop("iiasatemplate ", iiasatemplate , " does not exist.")
} else if (str_sub(iiasatemplate, -5, -1) == ".xlsx") {
  for (i in seq(20)) {
    template <- read_excel(iiasatemplate, sheet = i)
    if ("Variable" %in% names(template)) {
      templatevariables <- template$Variable
      break
    }
  }
} else if (str_sub(iiasatemplate, -5, -1) == ".yaml") {
  template <- unlist(read_yaml(iiasatemplate), recursive = FALSE)
  templatevariables <- names(template)
} else {
  stop("iiasatemplate ", iiasatemplate , " is neither xlsx nor yaml, so I don't understand it.")
}

if (! exists("templatevariables")) {
  stop("No 'Variable' found in iiasatemplate ", iiasatemplate)
}
variables_not_in_template <- unique( data$variable[! data$variable %in% templatevariables])

message("# ", length(variables_not_in_template), " variables not in IIASA template are deleted, see ", LOGFILE, ".")
write(paste0("\n\n#--- ", length(variables_not_in_template), " variables not in IIASAtemplate ", iiasatemplate,
             " are deleted ---#"), file = LOGFILE, append = TRUE)
write(paste0("  - ", paste(variables_not_in_template, collapse = "\n  - ")), file = LOGFILE, append = TRUE)

message("# ", length(temporarydelete), " variables are in the list to be temporarily deleted, ",
        length(unique(data$variable[data$variable %in% temporarydelete])), " were deleted, see ", LOGFILE, ".")
write(paste0("\n\n#--- ", length(variables_not_in_template), " variables are in temporarydelete. ",
      length(unique(data$variable[data$variable %in% temporarydelete])), " were deleted ---#"),
      file = LOGFILE, append = TRUE)
write(paste0("  - ", paste(unique(data$variable[data$variable %in% temporarydelete]), collapse = "\n  - ")), file = LOGFILE, append = TRUE)

data <- data %>%
  mutate(value = ifelse(!is.finite(value) | is.na(value), 0, value)) %>%
  mutate(scenario=gsub("NA", "", scenario)) %>%
  filter(variable %in% templatevariables) %>%
  filter(! variable %in% temporarydelete)

# some basic checks
scenarios <- unique(data$variable)
for (i in 1:length(scenarios)) {
  stopifnot(length(filter(data, variable %in% scenarios[[1]])) == length(filter(data, variable %in% scenarios[[i]])))
}

file.remove(OUTPUT_mif)
write.mif(data, OUTPUT_mif)

# filter(scenario == "d_delfrag") %>%

data %>%
  mutate(value = ifelse(!is.finite(value) | paste(value) == "", 0, value)) %>%
  pivot_wider(names_from="period", values_from="value") -> writetoexcel

writexl::write_xlsx(list("data" = writetoexcel), OUTPUT_xlsx)

message("\n### mif files: ", sum(existingfiles), " used, ", sum(! existingfiles), " not found, see above.")
message("\n### Output files written:\n- ", OUTPUT_mif, "\n- ", OUTPUT_xlsx, "\n")
