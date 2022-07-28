*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/module.gms
*' @title Buildings
*'
*' @description  The 36_buildings module calculates the demand for energy from buildings.
*'
*'               The `simple` realization only gives a representation of the demand for energy carriers.
*'               The `services_with_capital` realization distinguishes between end-uses and adds a trade-off between energy consumption and capital investments.
*'               The `services_putty` realization uses `services_with_capital` as a basis, but adds inertia dynamics to the improvement of building envelopes (insulation).
*'
*' @authors Antoine Levesque, Robin Krekeler
*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%buildings%" == "services_putty" $include "./modules/36_buildings/services_putty/realization.gms"
$Ifi "%buildings%" == "services_with_capital" $include "./modules/36_buildings/services_with_capital/realization.gms"
$Ifi "%buildings%" == "simple" $include "./modules/36_buildings/simple/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/36_buildings/module.gms
