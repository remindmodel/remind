# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(remind2)
library(lucode2)

############################# BASIC CONFIGURATION #############################

if(!exists("source_include")) {
  #Define arguments that can be read from command line
   outputdir <- "output/R17IH_SSP2_postIIASA-26_2016-12-23_16.03.23"     # path to the output folder
   readArgs("outputdir")
} 

scenario               <- getScenNames(outputdir)
remind_reporting_file  <- path(outputdir,paste0("REMIND_generic_",scenario,".mif"))
gdx                    <- path(outputdir,"fulldata.gdx")
hist                   <- c(paste0(outputdir, "/historical.mif"), "./core/input/historical/historical.mif")
name_of_output_pdf     <- path(outputdir,paste0("REMIND_summary_",scenario,".pdf"))

#### Choose validation data ###
# Use first hist file that can be found
for(h in hist) {
  if(file.exists(h)) break
}

# generate validation for REMIND
validationSummary(gdx=gdx, hist=h, reportfile=remind_reporting_file, outfile=name_of_output_pdf)
