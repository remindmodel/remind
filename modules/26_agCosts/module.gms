*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/26_agCosts/26_agCosts.gms

*' @title Agricultural costs
*'
*' @description This module calculates the costs for agricultural production which is exogenous to REMIND.
*'
*' @authors Franziska Piontek, David Klein

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%agCosts%" == "costs" $include "./modules/26_agCosts/costs/realization.gms"
$Ifi "%agCosts%" == "costs_trade" $include "./modules/26_agCosts/costs_trade/realization.gms"
$Ifi "%agCosts%" == "off" $include "./modules/26_agCosts/off/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/26_agCosts/26_agCosts.gms
