*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/70_water/70_water.gms

*' @title Water
*'
*' @description  The 70_water module calculates water demand in a post-processing mode if it is turned on. The method and results are described in @Mouratiadou2016.
*'
*' @authors Ioanna Mouratiadou

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%water%" == "exogenous" $include "./modules/70_water/exogenous/realization.gms"
$Ifi "%water%" == "heat" $include "./modules/70_water/heat/realization.gms"
$Ifi "%water%" == "off" $include "./modules/70_water/off/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/70_water/70_water.gms
