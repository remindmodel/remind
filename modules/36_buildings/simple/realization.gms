*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/simple.gms

*' @description 
*' 
*'The `simple` realization represents buildings energy demand within the CES function.
*'It displays the energy demand for six energy carrier categories (electricity, solids, liquids, gas, district heating, hydrogen),
*'at the final energy level.
*'In policy scenarios, energy demand reacts to modified prices by switching to energy carriers whose relative prices decrease.
*'
*' @limitations This realization does not distinguish across end-uses.
*'Also, it does not allow for substitution between energy consumption and end-use capital

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/36_buildings/simple/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/36_buildings/simple/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/36_buildings/simple/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/36_buildings/simple/equations.gms"
$Ifi "%phase%" == "bounds" $include "./modules/36_buildings/simple/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/36_buildings/simple/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/36_buildings/simple.gms
