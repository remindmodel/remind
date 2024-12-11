*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/15_climate/module.gms

*' @title climate
*'
*' @description  
*' The 15_climate module takes emissions and simulates the resulting climate variables (forcings, global mean temperature)
*' using the MAGICC climate emulator. It may also be used within the optimization or between iterations
*' in order to internalize climate damages or adjust the carbon price to meet a desired climate target
*'
*' @authors Jessica Strefler, Michaja Pehl, Christoph Bertram, Gabriel Abrahão, Tonn Rüter

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%climate%" == "magicc7_ar6" $include "./modules/15_climate/magicc7_ar6/realization.gms"
$Ifi "%climate%" == "off" $include "./modules/15_climate/off/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/15_climate/module.gms
