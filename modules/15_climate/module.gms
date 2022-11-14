*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
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
*' using either the MAGICC climate emulator or a stylized box model. These may also be used within the optimization or between iterations
*' in order to internalize climate damages or adjust the carbon price to meet a desired climate target
*'
*' @authors Jessica Strefler, Michaja Pehl, Christoph Bertram

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%climate%" == "box" $include "./modules/15_climate/box/realization.gms"
$Ifi "%climate%" == "magicc" $include "./modules/15_climate/magicc/realization.gms"
$Ifi "%climate%" == "off" $include "./modules/15_climate/off/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/15_climate/module.gms
