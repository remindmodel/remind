*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/KWTCint/realization.gms

*' @description Combines output damages from Kalkuhl & Wenz 2020 (aggregate productivity damages as in module KWLike) and tropical cyclone damages from Krichene et al. 2022 (as in module TC). They should be additive as the former does not include effects of extreme events.

*' @limitations: Unless the realization "KWTCitr" is used for module 51_internalizeDamages, the damages are not actually part of the optimization, but just enter as a fixed variable reducing output, updated in between iterations.  

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/50_damages/KWTCint/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/50_damages/KWTCint/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/50_damages/KWTCint/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/50_damages/KWTCint/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/50_damages/KWTCint/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/50_damages/KWTCint/realization.gms
