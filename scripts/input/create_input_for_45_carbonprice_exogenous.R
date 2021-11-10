# |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
### Function to create files with price mark-ups (needed for cm_fetaxscen 102 - 116, ADVANCE WP2 price elasticity runs)

create_input_for_45_carbonprice_exogenous<-function(gdx){
  
  library(luplot,quietly=TRUE,warn.conflicts =FALSE)
  library(gms,quietly=TRUE,warn.conflicts =FALSE)
  require(remind2,quietly = TRUE,warn.conflicts =FALSE)
  
  ############################# BASIC CONFIGURATION #############################
  
  #Define arguments that can be read from command line
  #  gdx <- "fulldata.gdx"
  #  readArgs("fulldata.gdx")
  
  ###############################################################################
  
  if (file.exists(gdx)) {
    pr <- reportPrices(gdx)
  } else {
    stop("No gdx file found to take the carbon price from - please provide gdx from a reference run in path_gdx_carbonprice in scenario_config file.")
  }
  
  #select right temporal/variable scope 
  pr <- pr[,,c( "Price|Carbon (US$2005/t CO2)")]
  #get rid of variable name so that it is not printed
  pr <- pr[,,1,drop=TRUE]
  
  #write out file for mark-ups applied on FE level
  write.magpie(pr[seq(1,11),,],"modules/45_carbonprice/exogenous/input/p45_tau_co2_tax.inc", comment="** description: Carbon prices from previous run \n*** unit: $2005/t CO2 \n*** file created with scripts/input/create_input_for_45_carbonprice_exogenous.R")
}
