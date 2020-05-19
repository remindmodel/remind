# |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(lucode) # getScenNames
slurm <- suppressWarnings(ifelse(system2('srun',stdout=FALSE,stderr=FALSE) != 127, TRUE, FALSE))
  if (slurm) { 
    library('remind',lib.loc = '/p/projects/innopaths/reporting_library/lib/')  
  } else {
    library(remind)
  } # compareScenarios

if(!exists("source_include")) {
  readArgs("outputdirs")
  readArgs("shortTerm")
  readArgs("outfilename")
  readArgs("regions")
  readArgs("mainReg")
}

wrap_to_have_a_clean_exit <- function(outputdirs,shortTerm,outfilename,regions,mainReg) {
  # Set mif path
  scenNames <- getScenNames(outputdirs)
  # Note: add '../' infront of the paths because the compareScenario functions will be run in individual temporary subfolders (see below for explanation)
  mif_path  <- path("../",outputdirs,paste("REMIND_generic_",scenNames,".mif",sep=""))
  hist_path <- path("../",outputdirs[1],"historical.mif")

  # Create temporary folder. This is necessary because each compareScenario creates a folder names 'figure'.
  # If multiple compareScenario run in parallel they would interfere with the others' figure folder.
  # So we create a temporary subfolder in which each compareScenario creates its own figure folder.
  outfilename <- if(mainReg!="GLO") paste0(outfilename, "-" , mainReg)
  system(paste0("mkdir ",outfilename))
  merke <- getwd()

  setwd(outfilename)
  # remove temporary folder
  on.exit(system(paste0("mv ",outfilename,".pdf ..")))
  on.exit(setwd(merke), add = TRUE)
  on.exit(system(paste0("rm -rf ",outfilename)), add = TRUE)

  
  if (!shortTerm) {
    try(compareScenarios(mif=mif_path, hist=hist_path, reg=regions, mainReg=mainReg, fileName = paste0(outfilename,".pdf")))
  } else {
    try(compareScenarios(mif=mif_path, hist=hist_path, reg=regions, mainReg=mainReg, y=c(seq(2005,2050,5)), y_hist=c(seq(1990,2015,1)), y_bar=c(2010,2030,2050), fileName=paste0(outfilename,".pdf")))
  }
}

wrap_to_have_a_clean_exit(outputdirs,shortTerm,outfilename,regions,mainReg)
