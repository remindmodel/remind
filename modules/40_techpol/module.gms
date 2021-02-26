*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/40_techpol.gms

*' @title Techpol
*'
*' @description  The 40_techpol module formulates technological policies. They can be part of a baseline or climate policy scenario.
*'
*' @authors Christoph Bertram, Falko Ueckertd

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%techpol%" == "CombLowCandCoalPO" $include "./modules/40_techpol/CombLowCandCoalPO/realization.gms"
$Ifi "%techpol%" == "EVmandates" $include "./modules/40_techpol/EVmandates/realization.gms"
$Ifi "%techpol%" == "NDC2018" $include "./modules/40_techpol/NDC2018/realization.gms"
$Ifi "%techpol%" == "NDC2018plus" $include "./modules/40_techpol/NDC2018plus/realization.gms"
$Ifi "%techpol%" == "NPi2018" $include "./modules/40_techpol/NPi2018/realization.gms"
$Ifi "%techpol%" == "coalPhaseout" $include "./modules/40_techpol/coalPhaseout/realization.gms"
$Ifi "%techpol%" == "coalPhaseoutRegional" $include "./modules/40_techpol/coalPhaseoutRegional/realization.gms"
$Ifi "%techpol%" == "lowCarbonPush" $include "./modules/40_techpol/lowCarbonPush/realization.gms"
$Ifi "%techpol%" == "none" $include "./modules/40_techpol/none/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/40_techpol/40_techpol.gms
