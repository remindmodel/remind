*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/realization.gms

*' @description  
*'
*'The `regiCarbonPrice` realization allow to determine region specific year or budget targets for CO2 or GHG emissions.
*'
*'This allows to determine regions with more (or less) stringent carbon policies than the World targets.
*'
*'Ex.: EU emission targets are tipically more stringent than other World regions. 
*'
*' @authors Renato Rodrigues, Felix Schreyer 

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/47_regipol/regiCarbonPrice/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/47_regipol/regiCarbonPrice/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/47_regipol/regiCarbonPrice/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/47_regipol/regiCarbonPrice/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/47_regipol/regiCarbonPrice/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/47_regipol/regiCarbonPrice/bounds.gms"
$Ifi "%phase%" == "presolve" $include "./modules/47_regipol/regiCarbonPrice/presolve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/47_regipol/regiCarbonPrice/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/47_regipol/regiCarbonPrice/realization.gms
