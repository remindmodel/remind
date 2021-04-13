# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(magclass)
library(remind2)
library(gms)
library(lucode2)
library(methods)
############################# BASIC CONFIGURATION #############################
gdx_name     <- "fulldata.gdx"        # name of the gdx  

if(!exists("source_include")) {
  #Define arguments that can be read from command line
   outputdir <- "output/R17IH_SSP2_postIIASA-26_2016-12-23_16.03.23"     # path to the output folder
   readArgs("outputdir","gdx_name")
} 

gdx      <- path(outputdir,gdx_name)
scenario <- getScenNames(outputdir)
###############################################################################
# paths of the pdf file
file_name <- path(outputdir,paste0("convergenceCheck_",scenario,".pdf"))

# produce convergende pdf based on gdx information
convergenceCheck(gdx,file=file_name) 
