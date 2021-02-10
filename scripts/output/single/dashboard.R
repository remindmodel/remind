# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

#' @title REMIND dashboard
#' @description Create REMIND dashboard results for single runs
#'
#' @author Renato Rodrigues
#' 

library(lucode2)
library(rmarkdown)
library(remind2)

############################# BASIC CONFIGURATION #############################

if(!exists("source_include")) {
  #Define arguments that can be read from command line
   outputdir <- NULL     # path to the output folder
   readArgs("outputdir")
} 

scenario <- getScenNames(outputdir)
reportfile <- path(getwd(),outputdir,paste0("REMIND_generic_",scenario,".mif"))
gdx <- path(getwd(),outputdir,"fulldata.gdx")
statsFile <- path(getwd(),outputdir,"runstatistics.rda")
load(file = path(getwd(),outputdir,"config.Rdata"))
regionMapping <- cfg$regionmapping

histFiles <- c(path(getwd(),outputdir, "/historical.mif"), path(getwd(),"./core/input/historical/historical.mif"))
for(hist in histFiles) { # Use first hist file that can be found
  if(file.exists(hist)) break
}

# path of the dashboard file
output_file <- path(getwd(),outputdir,paste0("REMIND_dashboard_",scenario,".html"))

# generate dashboard for REMIND
dashboard(gdx=gdx, statsFile=statsFile, regionMapping=regionMapping, hist=hist, reportfile=reportfile, output_file=output_file)

