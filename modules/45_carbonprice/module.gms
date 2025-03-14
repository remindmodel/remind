*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/module.gms

*' @title Carbonprice
*'
*' @description
*' The carbonprice module sets or adjusts carbon price trajectories between iterations s.t. the desired climate policy targets are met.
*' Carbon price trajectories either (a) follow  a prescribed funtional form (linear/exponential), (b) relect NPi or NDC targets, or (c) are set exogenously. 
*' The carbon price is the main indicator to reflect the change in climate policy ambition over time.

*' Carbon prices are potentially defined by three modules:
*' - 45_carbonprice: define the carbon price necessary to reach global emission targets following specific price trajectories.
*' - 46_carbonpriceRegi: add a markup pm_taxCO2eqRegi to 45_carbonprice estimations to reach specific NDC or net zero targets
*' - 47_regipol: under the regiCarbonPrice realisation, define more detailed region or emissions market specific targets, overwriting the all other carbon prices for selected regions.

*' @authors Christoph Bertram, Laurin Koehler-Schindler, Gunnar Luderer, Rahel Mandaroux, Robert Pietzcker, Oliver Richters

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%carbonprice%" == "NDC" $include "./modules/45_carbonprice/NDC/realization.gms"
$Ifi "%carbonprice%" == "NDCexpo" $include "./modules/45_carbonprice/NDCexpo/realization.gms"
$Ifi "%carbonprice%" == "NPi" $include "./modules/45_carbonprice/NPi/realization.gms"
$Ifi "%carbonprice%" == "NPi2025" $include "./modules/45_carbonprice/NPi2025/realization.gms"
$Ifi "%carbonprice%" == "NPi2025expo" $include "./modules/45_carbonprice/NPi2025expo/realization.gms"
$Ifi "%carbonprice%" == "exogenous" $include "./modules/45_carbonprice/exogenous/realization.gms"
$Ifi "%carbonprice%" == "expoLinear" $include "./modules/45_carbonprice/expoLinear/realization.gms"
$Ifi "%carbonprice%" == "functionalForm" $include "./modules/45_carbonprice/functionalForm/realization.gms"
$Ifi "%carbonprice%" == "none" $include "./modules/45_carbonprice/none/realization.gms"
$Ifi "%carbonprice%" == "temperatureNotToExceed" $include "./modules/45_carbonprice/temperatureNotToExceed/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/45_carbonprice/module.gms
