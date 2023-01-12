# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(magclass)
library(remind2)
library(lucode2)
library(gms)
library(methods)
library(edgeTransport)
library(quitte)
############################# BASIC CONFIGURATION #############################
gdx_name     <- "fulldata.gdx"             # name of the gdx
gdx_ref_name <- "input_refpolicycost.gdx"  # name of the reference gdx (for policy cost calculation)


if(!exists("source_include")) {
   # Define arguments that can be read from command line
   outputdir <- "."
   readArgs("outputdir", "gdx_name", "gdx_ref_name")
}

gdx      <- file.path(outputdir,gdx_name)
gdx_ref  <- file.path(outputdir,gdx_ref_name)
if (!file.exists(gdx_ref)) { gdx_ref <- NULL }
scenario <- getScenNames(outputdir)
###############################################################################
# paths of the reporting files
remind_reporting_file <- file.path(outputdir,paste0("REMIND_generic_",scenario,".mif"))
magicc_reporting_file <- file.path(outputdir,paste0("REMIND_climate_", scenario, ".mif"))
LCOE_reporting_file   <- file.path(outputdir,paste0("REMIND_LCOE_", scenario, ".csv"))

remind_policy_reporting_file <- file.path(outputdir,paste0("REMIND_generic_",scenario,"_adjustedPolicyCosts.mif"))
remind_policy_reporting_file <- remind_policy_reporting_file[file.exists(remind_policy_reporting_file)]
if (length(remind_policy_reporting_file) > 0) {
  unlink(remind_policy_reporting_file)
  message("\n", paste(basename(remind_policy_reporting_file), collapse = ", "), " deleted.")
  message(paste(basename(remind_reporting_file), collapse = ", "), " will contain policy costs based on input_refpolicycost.gdx.")
}

# produce REMIND reporting *.mif based on gdx information
message("\n### start generation of mif files at ", Sys.time())
tmp <- try(convGDX2MIF(gdx,gdx_ref,file=remind_reporting_file,scenario=scenario)) # try to execute convGDX2MIF
if(class(tmp)=="try-error") convGDX2MIF_REMIND2MAgPIE(gdx, file = remind_reporting_file, scenario = scenario)

#  MAGICC code not working with REMIND-EU
# generate MAGICC reporting and append to REMIND reporting
if (0 == nchar(Sys.getenv('MAGICC_BINARY'))) {
  warning('Can\'t find magicc executable under environment variable MAGICC_BINARY')
} else {
  message("Generate ", basename(magicc_reporting_file))
  system(paste("cd ",outputdir ,"/magicc; ",
             "pwd;",
             "sed -f modify_MAGCFG_USER_CFG.sed -i MAGCFG_USER.CFG; ",
             Sys.getenv('MAGICC_BINARY'), '; ',
             "awk -f MAGICC_reporting.awk -v c_expname=\"", scenario, "\"",
             " < climate_reporting_template.txt ",
             " > ","../../../", magicc_reporting_file,"; ",
             "sed -i 's/;glob;/;World;/g' ","../../../", magicc_reporting_file, "; ",
             "cat ", "../../../",magicc_reporting_file, " >> ", "../../../",remind_reporting_file, "; ",
             sep = ""))
}


## generate EDGE-T reporting if it is needed
## the reporting is appended to REMIND_generic_<scenario>.MIF
## REMIND_generic_<scenario>_withoutPlus.MIF is replaced.

edgetOutputDir <- file.path(outputdir, "EDGE-T")
if(file.exists(edgetOutputDir)) {
  if (! file.exists(file.path(edgetOutputDir, "demandF_plot_pkm.RDS"))) {
    message("EDGE-T reporting files are missing, probably because the run was killed.")
    message("Rerunning toolIterativeEDGETransport(reporting = TRUE).")
    savewd <- getwd()
    setwd(outputdir)
    edgeTransport::toolIterativeEDGETransport(reporting = TRUE)
    setwd(savewd)
  }
  message("start generation of EDGE-T reporting")
  EDGET_output <- toolReportEDGET(edgetOutputDir,
                                  extendedReporting = FALSE,
                                  scenario_title = scenario, model_name = "REMIND",
                                  gdx = file.path(outputdir, "fulldata.gdx"))

  write.mif(EDGET_output, remind_reporting_file, append = TRUE)
  deletePlus(remind_reporting_file, writemif = TRUE)

  message("end generation of EDGE-T reporting")
}

configfile <- file.path(outputdir, "config.Rdata")
envir <- new.env()
load(configfile, envir = envir)
magpie_reporting_file <- envir$cfg$pathToMagpieReport
if (! is.null(magpie_reporting_file) && file.exists(magpie_reporting_file)) {
  message("add MAgPIE reporting from ", magpie_reporting_file)
  tmp_rem <- read.report(remind_reporting_file, as.list=FALSE)
  tmp_mag <- read.report(magpie_reporting_file, as.list=FALSE)[, getYears(tmp_rem), ]
  # harmonize scenario name from -mag-xx to -rem-xx
  getNames(tmp_mag, dim = 1) <- paste0(scenario)
  tmp_rem_mag <- mbind(tmp_rem, tmp_mag)
  if (any(getNames(tmp_rem_mag[, , "REMIND"], dim = 3) %in% getNames(tmp_rem_mag[, , "MAgPIE"], dim = 3))) {
    message("Cannot produce common REMIND-MAgPIE reporting because there are identical variable names in both models!")
  } else {
    write.report(tmp_rem_mag, file = remind_reporting_file, ndigit = 7)
    deletePlus(remind_reporting_file, writemif = TRUE)
  }
}

message("### end generation of mif files at ", Sys.time())

## produce REMIND LCOE reporting *.csv based on gdx information
message("start generation of LCOE reporting")
tmp <- try(convGDX2CSV_LCOE(gdx,file=LCOE_reporting_file,scen=scenario)) # execute convGDX2MIF_LCOE
message("end generation of LCOE reporting")

## generate DIETER reporting if it is needed
## the reporting is appended to REMIND_generic_<scenario>.MIF in "DIETER" Sub Directory
DIETERGDX <- "report_DIETER.gdx"
if(file.exists(file.path(outputdir, DIETERGDX))){
  message("start generation of DIETER reporting")
  remind2::reportDIETER(DIETERGDX,outputdir)
  message("end generation of DIETER reporting")
}

message("### reporting finished.")
