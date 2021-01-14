*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/30_biomass/30_biomass.gms

*' @title Biomass
*'
*' @description The biomass module calculates the production costs of all types of primary energy 
*' biomass.
*'
*' @authors David Klein

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%biomass%" == "exogenous" $include "./modules/30_biomass/exogenous/realization.gms"
$Ifi "%biomass%" == "magpie_40" $include "./modules/30_biomass/magpie_40/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/30_biomass/30_biomass.gms
