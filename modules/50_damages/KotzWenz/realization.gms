*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/KotzWenz/realization.gms

*' @description Aggregate GDP damages based on Kotz et al. (2024). They are calculated on country level for 1000 Monte Carlo realizations, then the chosen percentile of this damage distribution is used in the further calculations. The damages are calculated with respect to temperature changes compared to 2020, assuming that the 2020 GDP already includes all climate damages.

*' @limitations: Unless the realization "KotzWenzItr" is used for module 51_internalizeDamages, the damages are not actually part of the optimization, but just enter as a fixed variable reducing output, updated in between iterations.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/50_damages/KotzWenz/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/50_damages/KotzWenz/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/50_damages/KotzWenz/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/50_damages/KotzWenz/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/50_damages/KotzWenz/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/50_damages/KotzWenz/realization.gms
