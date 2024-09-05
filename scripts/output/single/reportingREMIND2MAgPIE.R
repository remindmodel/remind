# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
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
library(piamutils)
############################# BASIC CONFIGURATION #############################
gdx_name     <- "fulldata.gdx"             # name of the gdx

if(!exists("source_include")) {
   # Define arguments that can be read from command line
   outputdir <- "."
   readArgs("outputdir", "gdx_name")
}

gdx      <- file.path(outputdir,gdx_name)
scenario <- getScenNames(outputdir)

configfile <- file.path(outputdir, "config.Rdata")
envir <- new.env()
load(configfile, envir = envir)

###############################################################################
# paths of the reporting files
remind_reporting_file <- file.path(outputdir,paste0("REMIND_generic_",scenario,".mif"))

# produce REMIND reporting *.mif based on gdx information
message("\n### start generation of mif files at ", round(Sys.time()))
convGDX2MIF_REMIND2MAgPIE(gdx, file = remind_reporting_file, scenario = scenario)

magpie_reporting_file <- envir$cfg$pathToMagpieReport
if (! is.null(magpie_reporting_file) && file.exists(magpie_reporting_file)) {
  message("add MAgPIE reporting from ", magpie_reporting_file)
  tmp_rem <- quitte::as.quitte(remind_reporting_file)
  tmp_mag <- dplyr::filter(quitte::as.quitte(magpie_reporting_file), .data$period %in% unique(tmp_rem$period))
  # remove population from magpie reporting to avoid duplication (units "million" vs. "million people")
  sharedvariables <- intersect(tmp_mag$variable, tmp_rem$variable)
  if (length(sharedvariables) > 0) {
    message("The following variables will be dropped from MAgPIE reporting because they are in REMIND reporting: ", paste(sharedvariables, collapse = ", "))
    tmp_mag <- dplyr::filter(tmp_mag, ! .data$variable %in% sharedvariables)
  }
  # harmonize scenario name from -mag-xx to -rem-xx
  tmp_mag$scenario <- paste0(scenario)
  tmp_rem_mag <- rbind(tmp_rem, tmp_mag)
  quitte::write.mif(tmp_rem_mag, path = remind_reporting_file)
  piamutils::deletePlus(remind_reporting_file, writemif = TRUE)
}

message("### end generation of mif files at ", round(Sys.time()))
message("### reporting finished.")
