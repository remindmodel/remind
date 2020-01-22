*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/01_macro/module.gms
*' @title Macro-Economic Growth Model
*'
*' @description The macro module allows for the implementation of different 
*' macro-economic modules. 
*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%macro%" == "singleSectorGr" $include "./modules/01_macro/singleSectorGr/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/01_macro/module.gms
