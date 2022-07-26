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
gdx_ref_name <- "input_refpolicycost.gdx"  # name of the reference gdx (for policy cost calculation)


if(!exists("source_include")) {
  #Define arguments that can be read from command line
   outputdir <- "output/R17IH_SSP2_postIIASA-26_2016-12-23_16.03.23"     # path to the output folder
   readArgs("outputdir","gdx_name","gdx_ref_name")
}

gdx      <- file.path(outputdir,gdx_name)
gdx_ref  <- file.path(outputdir,gdx_ref_name)
if(!file.exists(gdx_ref)) { gdx_ref <- NULL }
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
if(class(tmp)=="try-error") convGDX2MIF_fallback_for_coupling(gdx,file=remind_reporting_file,scenario=scenario)

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
             "sed -i 's/glob/World/g' ","../../../", magicc_reporting_file, "; ",
             "cat ", "../../../",magicc_reporting_file, " >> ", "../../../",remind_reporting_file, "; ",
             sep = ""))
}


## generate EDGE-T reporting if it is needed
## the reporting is appended to REMIND_generic_<scenario>.MIF
## REMIND_generic_<scenario>_withoutPlus.MIF is replaced.

if(file.exists(file.path(outputdir, "EDGE-T"))){
message("start generation of EDGE-T reporting")
  reportEDGETransport(outputdir)
message("end generation of EDGE-T reporting")
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
