*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/25_WACC/module.gms

*' @title WACC Module
*'
*' @description The WACC module calculates the WACC related costs on technology investments. 

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%WACC%" == "off" $include "./modules/25_WACC/off/realization.gms"
$Ifi "%WACC%" == "standard" $include "./modules/25_WACC/standard/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/25_WACC/module.gms
