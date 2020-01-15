*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/module.gms
*' @title Trade module
*'
*' @description This file loads the trade module realization.
*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%trade%" == "standard" $include "./modules/24_trade/standard/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/24_trade/module.gms
