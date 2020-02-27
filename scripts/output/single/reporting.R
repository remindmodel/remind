# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(magclass)
library(remind)
library(lucode)
library(methods)
############################# BASIC CONFIGURATION #############################
gdx_name     <- "fulldata.gdx"        # name of the gdx  
gdx_ref_name <- "input_ref.gdx"       # name of the reference gdx (for policy cost calculation)
 

if(!exists("source_include")) {
  #Define arguments that can be read from command line
   outputdir <- "output/R17IH_SSP2_postIIASA-26_2016-12-23_16.03.23"     # path to the output folder
   readArgs("outputdir","gdx_name","gdx_ref_name")
} 

gdx      <- path(outputdir,gdx_name)
gdx_ref  <- path(outputdir,gdx_ref_name)
if(!file.exists(gdx_ref)) { gdx_ref <- NULL }
scenario <- getScenNames(outputdir)
###############################################################################
# paths of the reporting files
remind_reporting_file <- path(outputdir,paste0("REMIND_generic_",scenario,".mif"))
magicc_reporting_file <- path(outputdir,paste0("REMIND_climate_", scenario, ".mif"))
LCOE_reporting_file   <- path(outputdir,paste0("REMIND_LCOE_", scenario, ".mif"))

# produce REMIND reporting *.mif based on gdx information
tmp <- try(convGDX2MIF(gdx,gdx_ref,file=remind_reporting_file,scenario=scenario)) # try to execute convGDX2MIF
if(class(tmp)=="try-error") convGDX2MIF_fallback_for_coupling(gdx,file=remind_reporting_file,scenario=scenario)

# generate MAGICC reporting and append to REMIND reporting
if (0 == nchar(Sys.getenv('MAGICC_BINARY'))) {
  warning('Can\'t find magicc executable under environment variable MAGICC_BINARY')
} else {
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
  reportEDGETransport(outputdir)
}

# produce REMIND LCOE reporting *.mif based on gdx information
tmp <- try(convGDX2MIF_LCOE(gdx,gdx_ref,file=LCOE_reporting_file,scenario=scenario)) # execute convGDX2MIF_LCOE

