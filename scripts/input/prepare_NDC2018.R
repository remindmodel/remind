# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
### Function to create files with regional BAU emissions

prepare_NDC2018<-function(gdx){
  
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
  p45_BAU_reg_emi_wo_LU_bunkers <- emi[regs,seq(2005,2050,5),"Emi|Kyoto Gases excl Land-Use Change|w/o Bunkers (Mt CO2-equiv/yr)"]
  
  getNames(p45_BAU_reg_emi_wo_LU_bunkers) <- NULL
  write.magpie(p45_BAU_reg_emi_wo_LU_bunkers,"modules/45_carbonprice/NDC2018/input/p45_BAU_reg_emi_wo_LU_bunkers.cs4r", comment="** description: Regional GHG emi (excl. LU and bunkers) in BAU scenario \n*** unit: Mt CO2eq/yr \n*** file created with scripts/input/create_BAU_reg_emi_wo_LU_bunkers.R")
  #   
  
  #read current gdp_scen
  gdp_scen <- readGDX(gdx,"cm_GDPscen")
  
  shares <- as.magpie(read.csv("modules/45_carbonprice/NDC2018/input/p45_2005share_target.cs4r",skip=4,header = F))
  r2025 <- NULL
  r2030 <- NULL
  for(r in getRegions(shares)){
    ## depending on which target has the higher share of emissions, assign region to group with either 2025 or 2030 target year
    if(as.numeric(shares[r,2025,gdp_scen])>as.numeric(shares[r,2030,gdp_scen])){
      r2025 <- c(r2025,r)
    } else {
      r2030 <- c(r2030,r)
    }
  }
  
  # to be done: add up the shares from both time-steps to the dominant time step and copy the target value to the other time step
  # (assuming that the target is similar for the other time step - likely the minor error in comparison to not considering country at all)
  
  write.table(r2025,"modules/45_carbonprice/NDC2018/input/set_regi2025.cs4r", row.names = F,col.names=F,quote = F)
  write.table(r2030,"modules/45_carbonprice/NDC2018/input/set_regi2030.cs4r", row.names = F,col.names=F,quote = F)
}
