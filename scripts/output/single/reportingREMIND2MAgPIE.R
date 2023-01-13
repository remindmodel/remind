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
############################# BASIC CONFIGURATION #############################
gdx_name     <- "fulldata.gdx"             # name of the gdx

if(!exists("source_include")) {
   # Define arguments that can be read from command line
   outputdir <- "."
   readArgs("outputdir", "gdx_name")
}

gdx      <- file.path(outputdir,gdx_name)
scenario <- getScenNames(outputdir)
###############################################################################
# paths of the reporting files
remind_reporting_file <- file.path(outputdir,paste0("REMIND_generic_",scenario,".mif"))

# produce REMIND reporting *.mif based on gdx information
convGDX2MIF_RMEIND2MAgPIE(gdx, file = remind_reporting_file, scenario = scenario)

# create common REMIND-MAgPIE reporting by sticking individual REMIND and MAgPIE reporting mifs together
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
message("### reporting finished.")
