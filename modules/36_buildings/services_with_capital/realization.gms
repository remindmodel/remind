*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/services_with_capital.gms

*' @description 
*' 
*'The `services_with_capital` realization splits the representation of buildings energy demand between the CES structure
*' and a multinomial logit structure which distributes the demand across technologies.
*' Importantly, the realization distinguishes across four end-use categories (`appliances and lighting`, `water heating and cooking`,
*' `space cooling` and `space cooling` ).
*' Not only the demand for final energy is represented, but also the demand for useful energy, which is necessary to display the level of efficiency achieved.
*' In total, six energy carrier categories are included (electricity, solids, liquids, gas, district heating, hydrogen), spread across the various end-uses.
*' 
*' The model can decide to invest in end-use capital (insulation, appliances, space cooling) to reduce the energy demand, 
*' or it can switch to more efficient technologies to produce heat. 
*' The conversion efficiencies of the individual heat technologies is prescribed exogenously however.
*'
*' @limitations This realization does not represent inertia dynamics in the renovation of buildings.
*

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/36_buildings/services_with_capital/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/36_buildings/services_with_capital/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/36_buildings/services_with_capital/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/36_buildings/services_with_capital/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/36_buildings/services_with_capital/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/36_buildings/services_with_capital/bounds.gms"
$Ifi "%phase%" == "presolve" $include "./modules/36_buildings/services_with_capital/presolve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/36_buildings/services_with_capital/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/36_buildings/services_with_capital.gms
