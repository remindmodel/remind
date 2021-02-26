# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(lucode)
library(remind2)
library(lusweave)
library(mip)

############################# BASIC CONFIGURATION #############################

if(!exists("source_include")) {
  #Define arguments that can be read from command line
  outputdirs <- c("C:/Users/lavinia/Documents/MEINS/MO/comparisonREMIND17REMIND20/output/r7463c_SSP2-Base-rem-5",
                  "C:/Users/lavinia/Documents/MEINS/MO/comparisonREMIND17REMIND20/output/BAU_2018-04-28_11.23.55");   
  # path to the output folder
   readArgs("outputdirs")
} 

###############################################################################

# Set mif path
scenNames <- getScenNames(outputdirs)
mif_path  <- path(outputdirs,paste("REMIND_generic_",scenNames,".mif",sep=""))
hist_path <- path(outputdirs[1],"historical.mif")

# make comparision based on mif files
plotCDR(mif=mif_path, hist=hist_path, reg="all_reg")


