*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/39_CCU/39_CCU.gms

*' @title CCU
*'
*' @description  The 39_CCU module calculates emissions from synthetic gas and liquids.
*'
*' @authors Laura Popin, Jessica Strefler

*####################### R SECTION START (MODULETYPES) ##############################
$Ifi "%CCU%" == "off" $include "./modules/39_CCU/off/realization.gms"
$Ifi "%CCU%" == "on" $include "./modules/39_CCU/on/realization.gms"
*######################## R SECTION END (MODULETYPES) ###############################


*** EOF ./modules/39_CCU/39_CCU.gms
