# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(remind2)
library(reporttransport)
library(quitte)
library(piamutils)
library(lucode2)

############################# BASIC CONFIGURATION #############################

gdx_name     <- "fulldata.gdx"             # name of the gdx
gdx_ref_name <- "input_ref.gdx"            # name of the ref for < cm_startyear
gdx_refpolicycost_name <- "input_refpolicycost.gdx"  # name of the reference gdx (for policy cost calculation)

if (!exists("source_include")) {
  # Define arguments that can be read from command line
  outputdir <- "."
  lucode2::readArgs("outputdir", "gdx_name", "gdx_ref_name", "gdx_refpolicycost_name")
}

gdx     <- file.path(outputdir, gdx_name)
gdx_ref <- file.path(outputdir, gdx_ref_name)
gdx_refpolicycost <- file.path(outputdir, gdx_refpolicycost_name)
if (!file.exists(gdx_ref))           gdx_ref <- NULL
if (!file.exists(gdx_refpolicycost)) gdx_refpolicycost <- NULL
scenario <- lucode2::getScenNames(outputdir)

###############################################################################

# paths of the reporting files
remind_reporting_file <- file.path(outputdir, paste0("REMIND_generic_", scenario, ".mif"))
LCOE_reporting_file   <- file.path(outputdir, paste0("REMIND_LCOE_", scenario, ".csv"))

remind_policy_reporting_file <- file.path(outputdir, paste0("REMIND_generic_", scenario, "_adjustedPolicyCosts.mif"))
remind_policy_reporting_file <- remind_policy_reporting_file[file.exists(remind_policy_reporting_file)]

# path to extra data to be used in reporting
extra_data_path <- file.path(outputdir, "reporting")

if (length(remind_policy_reporting_file) > 0) {
  unlink(remind_policy_reporting_file)
  message("\n", paste(basename(remind_policy_reporting_file), collapse = ", "), " deleted.")
  message(paste0(basename(remind_reporting_file), collapse = ", "), " will contain policy costs based on ", basename(gdx_refpolicycost_name), ".")
}

# produce REMIND reporting *.mif based on gdx information ----
message("### start generation of mif files at ", round(Sys.time()))
convGDX2MIF(gdx, gdx_refpolicycost = gdx_refpolicycost,
            file = remind_reporting_file, scenario = scenario, gdx_ref = gdx_ref,
            extraData = extra_data_path)

# generate EDGE-T reporting ----
# the reporting is appended to REMIND_generic_<scenario>.MIF
# REMIND_generic_<scenario>_withoutPlus.MIF is replaced.

edgetOutputDir <- file.path(outputdir, "EDGE-T")

if (!file.exists(edgetOutputDir)) {
  stop("EDGE-T folder is missing")
}

message("### start generation of EDGE-T reporting")
EDGEToutput <- reporttransport::reportEdgeTransport(edgetOutputDir,
                                                    isTransportExtendedReported = FALSE,
                                                    modelName = "REMIND",
                                                    scenarioName = scenario,
                                                    gdxPath = file.path(outputdir, "fulldata.gdx"),
                                                    isStored = FALSE)

REMINDoutput <- read.quitte(file.path(outputdir, paste0("REMIND_generic_", scenario, "_withoutPlus.mif")))
sharedVariables <- EDGEToutput[variable %in% REMINDoutput$variable | grepl(".*edge", variable)]
EDGEToutput <- EDGEToutput[!(variable %in% REMINDoutput$variable | grepl(".*edge", variable))]
message("The following variables will be dropped from the EDGE-Transport reporting because ",
        "they are in the REMIND reporting: ", paste(unique(sharedVariables$variable), collapse = ", "))

# in order to append to the mif file, the periods 2005 and 2010 must be brought back
# see also: https://github.com/pik-piam/reporttransport/pull/38

if (!all(c(2005, 2010) %in% unique(EDGEToutput$period))) {
  tmp <- filter(EDGEToutput, .data$period == 2015)
  EDGEToutput <- rbind(
    EDGEToutput,
    mutate(tmp, "value" = NA, period = 2005),
    mutate(tmp, "value" = NA, period = 2010)
  )
}


quitte::write.mif(EDGEToutput, remind_reporting_file, append = TRUE)
piamutils::deletePlus(remind_reporting_file, writemif = TRUE)

# generate transport extended mif
reporttransport::reportEdgeTransport(edgetOutputDir,
                                     isTransportExtendedReported = TRUE,
                                     gdxPath = file.path(outputdir, "fulldata.gdx"),
                                     isStored = TRUE)

message("### end generation of EDGE-T reporting")

# extra emission reporting (depends on REMIND and EDGE-T variables) ----
message("### report additional emission variables (reportExtraEmissions)")
extraEmissions <- remind2::reportExtraEmissions(mif = remind_reporting_file,
                                                extraData = extra_data_path,
                                                gdx = gdx)
quitte::write.mif(extraEmissions, remind_reporting_file, append = TRUE)
piamutils::deletePlus(remind_reporting_file, writemif = TRUE)

# append MAgPIE reporting if available ----

envir <- new.env()
load(file.path(outputdir, "config.Rdata"), envir = envir)

magpie_reporting_file <- envir$cfg$pathToMagpieReport
if (!is.null(magpie_reporting_file) && file.exists(magpie_reporting_file)) {
  message("### add MAgPIE reporting from ", magpie_reporting_file)
  tmp_rem <- quitte::as.quitte(remind_reporting_file)
  tmp_mag <- dplyr::filter(quitte::as.quitte(magpie_reporting_file), .data$period %in% unique(tmp_rem$period))
  # remove common variables from magpie reporting to avoid duplication
  sharedvariables <- intersect(tmp_mag$variable, tmp_rem$variable)
  if (length(sharedvariables) > 0) {
    message("The following variables will be dropped from MAgPIE reporting because they are in REMIND reporting: ",
            paste(sharedvariables, collapse = ", "))
    tmp_mag <- dplyr::filter(tmp_mag, !.data$variable %in% sharedvariables)
  }
  # harmonize scenario name from -mag-xx to -rem-xx
  tmp_mag$scenario <- paste0(scenario)
  tmp_mag$value[! is.finite(tmp_mag$value)] <- NA # MAgPIE reports Inf https://github.com/pik-piam/magpie4/issues/70
  tmp_rem_mag <- rbind(tmp_rem, tmp_mag)
  quitte::write.mif(tmp_rem_mag, path = remind_reporting_file)
  piamutils::deletePlus(remind_reporting_file, writemif = TRUE)
}

# warn if duplicates in mif and incorrect spelling of variables ----
mifcontent <- read.quitte(sub("\\.mif$", "_withoutPlus.mif", remind_reporting_file), check.duplicates = FALSE)
quitte::reportDuplicates(mifcontent)

message("### end generation of mif files at ", round(Sys.time()))

# produce REMIND LCOE reporting *.csv based on gdx information ----

message("### start generation of LCOE reporting at ", round(Sys.time()))
remind2::convGDX2CSV_LCOE(gdx, file = LCOE_reporting_file, scen = scenario)
message("### end generation of LCOE reporting at ", round(Sys.time()))

message("### reporting finished.")
