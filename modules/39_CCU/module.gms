*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/39_CCU/39_CCU.gms

*' @title CCU
*'
*' @description  The 39_CCU module includes the possibliity to use synthetic gas and liquids. Synthetic gases and liquids
*' can be produced by the model if realization "on" is chosen. Synthetic gases and liquids refer to hydrocarbon liquid (e.g. petrol, diesel, kerosene) and gaseous
*' fuels based on a synthesis of hydrogen and captured CO2. In case of gaseous fuels (h22ch4), it is the methanation process, while in the case of liquid fuels (MeOH) 
*' it is either a route via Fischer-Tropsch based on hydrogen or a liquid production route via methanol. A differentiation of the latter two technologies is not necessary
*' due to similar technoeconomic characteristics. The resulting hydrocarbon fuels can then be used in all energy-demand sectors (transport,industry,buildings).
*' The two synfuel technologies (h22ch4,MeOH) convert secondary energy hydrogen to secondary energy liquids or gases. The captured CO2 can either come from
*' the energy supply technologies w/ capture, industry w/ capture and direct air capture. For the former two, it can have either fossil or biogenic origin. 
*'
*' @authors Laura Popin, Jessica Strefler, Felix Schreyer

*####################### R SECTION START (MODULETYPES) ##############################
$Ifi "%CCU%" == "off" $include "./modules/39_CCU/off/realization.gms"
$Ifi "%CCU%" == "on" $include "./modules/39_CCU/on/realization.gms"
*######################## R SECTION END (MODULETYPES) ###############################


*** EOF ./modules/39_CCU/39_CCU.gms
