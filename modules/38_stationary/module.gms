*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/38_stationary/38_stationary.gms
*' @title Stationary
*'
*' @description  The 38_stationary module represents the energy demand for the stationary sector (industry and buildings).
*' It cannot be used simulatenously with the modules 36 and 37 on buildings and industry
*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%stationary%" == "off" $include "./modules/38_stationary/off/realization.gms"
$Ifi "%stationary%" == "simple" $include "./modules/38_stationary/simple/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/38_stationary/38_stationary.gms
