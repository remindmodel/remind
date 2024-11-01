*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/70_water/module.gms

*' @title Water
*'
*' @description  This module calculates water consumption and withdrawals from cooling in electricity production.
*' The method and results are described detail in @Mouratiadou2016.
*' @authors Ioanna Mouratiadou

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%water%" == "heat" $include "./modules/70_water/heat/realization.gms"
$Ifi "%water%" == "off" $include "./modules/70_water/off/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/70_water/module.gms
