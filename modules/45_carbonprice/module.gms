*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/45_carbonprice.gms

*#' @title carbonprice
*#'
*#' @description
*#' The carbonprice module sets (exogenously given price path or predefined 2020 level and linear/exponential increase afterwards) 
*#' or adjusts carbon price trajectories between iterations s.t. the desired climate policy targets are met. The carbon price is the main indicator
*#' to reflect the increase in climate policy ambition over time. 

*#' @authors Christoph Bertram, Gunnar Luderer, Robert Pietzcker

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%carbonprice%" == "ExogSameAsPrevious" $include "./modules/45_carbonprice/ExogSameAsPrevious/realization.gms"
$Ifi "%carbonprice%" == "NDC2018" $include "./modules/45_carbonprice/NDC2018/realization.gms"
$Ifi "%carbonprice%" == "NDC2constant" $include "./modules/45_carbonprice/NDC2constant/realization.gms"
$Ifi "%carbonprice%" == "NPi2018" $include "./modules/45_carbonprice/NPi2018/realization.gms"
$Ifi "%carbonprice%" == "diffPhaseIn2Constant" $include "./modules/45_carbonprice/diffPhaseIn2Constant/realization.gms"
$Ifi "%carbonprice%" == "diffPhaseIn2Lin" $include "./modules/45_carbonprice/diffPhaseIn2Lin/realization.gms"
$Ifi "%carbonprice%" == "diffPhaseIn2LinFlex" $include "./modules/45_carbonprice/diffPhaseIn2LinFlex/realization.gms"
$Ifi "%carbonprice%" == "diffPhaseInLin2LinFlex" $include "./modules/45_carbonprice/diffPhaseInLin2LinFlex/realization.gms"
$Ifi "%carbonprice%" == "diffPriceSameCost" $include "./modules/45_carbonprice/diffPriceSameCost/realization.gms"
$Ifi "%carbonprice%" == "exogenous" $include "./modules/45_carbonprice/exogenous/realization.gms"
$Ifi "%carbonprice%" == "expoLinear" $include "./modules/45_carbonprice/expoLinear/realization.gms"
$Ifi "%carbonprice%" == "exponential" $include "./modules/45_carbonprice/exponential/realization.gms"
$Ifi "%carbonprice%" == "linear" $include "./modules/45_carbonprice/linear/realization.gms"
$Ifi "%carbonprice%" == "none" $include "./modules/45_carbonprice/none/realization.gms"
$Ifi "%carbonprice%" == "temperatureNotToExceed" $include "./modules/45_carbonprice/temperatureNotToExceed/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/45_carbonprice/45_carbonprice.gms
