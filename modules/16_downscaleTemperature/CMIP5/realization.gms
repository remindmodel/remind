*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/16_downscaleTemperature/CMIP5/CMIP5.gms

*' @description This produces the downscaled regional temperatures based on the exogenous downscaling factors and the MAGICC global mean temperature path. 

*' @limitations Downscaling factors are currently only available for RCPs 2.6 and 8.5, for the 11 and 12 region version. They can either be based on fixed 2010 population or changing population (currently only SSP2). The input files are currently hard-coded, so the different options cannot be chosen through a switch.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/16_downscaleTemperature/CMIP5/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/16_downscaleTemperature/CMIP5/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/16_downscaleTemperature/CMIP5/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/16_downscaleTemperature/CMIP5/CMIP5.gms
