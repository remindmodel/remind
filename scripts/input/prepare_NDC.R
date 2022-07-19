# |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
### Function to create files with regional BAU emissions

prepare_NDC<-function(gdx, cfg){

  library(luplot,quietly=TRUE,warn.conflicts =FALSE)
  library(lucode2,quietly=TRUE,warn.conflicts =FALSE)
  library(gdx,quietly=TRUE,warn.conflicts =FALSE)
  library(remind2,quietly = TRUE,warn.conflicts =FALSE)

  ############################# BASIC CONFIGURATION #############################

  #Define arguments that can be read from command line
  #  gdx <- "fulldata.gdx"
  #  readArgs("fulldata.gdx")

  ###############################################################################
  
  if (file.exists(gdx)) {
    emi <- reportEmi(gdx)
  } else {
    stop("No gdx file found - please provide gdx from reference BAU run")
  }
  regs <- setdiff(getRegions(emi),"GLO")
  if ("Emi|GHG|w/o Land-Use Change (Mt CO2eq/yr)" %in% getItems(emi,3.1)) {
      pm_BAU_reg_emi_wo_LU_bunkers <- emi[regs,seq(2005,2050,5),"Emi|GHG|w/o Land-Use Change (Mt CO2eq/yr)"]
  } else if ("Emi|Kyoto Gases excl Land-Use Change|w/o Bunkers (Mt CO2-equiv/yr)" %in% getItems(emi,3.1)) {
      pm_BAU_reg_emi_wo_LU_bunkers <- emi[regs,seq(2005,2050,5),"Emi|Kyoto Gases excl Land-Use Change|w/o Bunkers (Mt CO2-equiv/yr)"]
  } else {
     stop("No emissions variable found in the NDC script!") 
  }

  getNames(pm_BAU_reg_emi_wo_LU_bunkers) <- NULL
  write.magpie(pm_BAU_reg_emi_wo_LU_bunkers, "./modules/45_carbonprice/NDC/input/pm_BAU_reg_emi_wo_LU_bunkers.cs4r", comment="** description: Regional GHG emi (excl. LU and bunkers) in BAU scenario \n*** unit: Mt CO2eq/yr \n*** file created with scripts/input/prepare_NDC.R")
  write.magpie(pm_BAU_reg_emi_wo_LU_bunkers, "./modules/46_carbonpriceRegi/NDC/input/pm_BAU_reg_emi_wo_LU_bunkers.cs4r", comment="** description: Regional GHG emi (excl. LU and bunkers) in BAU scenario \n*** unit: Mt CO2eq/yr \n*** file created with scripts/input/prepare_NDC.R")
}
