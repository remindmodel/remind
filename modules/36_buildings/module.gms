*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/module.gms

*' @title Buildings
*'
*' @description  The Buildings module calculates the demand for energy from 
*' buildings. It is also referred to as Residential and Commercial.
*'
*' @authors Antoine Levesque, Robin Hasse

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%buildings%" == "services_putty" $include "./modules/36_buildings/services_putty/realization.gms"
$Ifi "%buildings%" == "services_with_capital" $include "./modules/36_buildings/services_with_capital/realization.gms"
$Ifi "%buildings%" == "simple" $include "./modules/36_buildings/simple/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/36_buildings/module.gms
