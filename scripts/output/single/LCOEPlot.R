# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(lucode)
library(remind)
library(lusweave)

############################# BASIC CONFIGURATION #############################

if(!exists("source_include")) {
  #Define arguments that can be read from command line
  outputdir <- c("C:/work/REMIND_tests/Trunk_latest/output/BAU_Nash_2019-02-13_12.27.58");   
  # path to the output folder
   lucode::readArgs("outputdir")
} 

###############################################################################

# Set mif path
scenNames <- getScenNames(outputdir)
mif_path  <- path(outputdir,paste("REMIND_LCOE_",scenNames,".mif",sep=""))


# run plot LCOE function
plotLCOE(mif_path)

