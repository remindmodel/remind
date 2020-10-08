*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/module.gms
*' @title Regional Policies
*'
*' @description  The 47_regipol module includes region specific policies.
*'
*'
*'               The `regiCarbonPrice` realization allow to determine region specific year or budget targets for CO2 or GHG emissions.
*'
*' @authors Renato Rodrigues, Felix Schreyer 

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%regipol%" == "none" $include "./modules/47_regipol/none/realization.gms"
$Ifi "%regipol%" == "regiCarbonPrice" $include "./modules/47_regipol/regiCarbonPrice/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################

*** EOF ./modules/47_regipol/module.gms
