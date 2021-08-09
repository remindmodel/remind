# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(magclass)
library(remind2)
library(lucode2)
library(methods)
library(tidyverse)
library(gdx)
library(rlang)
library(luscale)

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
remind_reporting_file <- path(outputdir,paste0("MOFEX_",scenario,".mif"))
# magicc_reporting_file <- path(outputdir,paste0("REMIND_climate_", scenario, ".mif"))
# LCOE_reporting_file   <- path(outputdir,paste0("REMIND_LCOE_", scenario, ".mif"))

# produce REMIND reporting *.mif based on gdx information
tmp <- try(reportMOFEX(gdx,gdx_ref,file=remind_reporting_file,scenario=scenario)) # try to execute convGDX2MIF

# produce REMIND LCOE reporting *.mif based on gdx information
# tmp <- try(convGDX2MIF_LCOE(gdx,gdx_ref,file=LCOE_reporting_file,scenario=scenario)) # execute convGDX2MIF_LCOE

