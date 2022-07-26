*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/Labor/realization.gms

*' @description Damages on labor supply from Dasgupta et al. (2021), implemented to directly affect labor in the budget equation. 

*' @limitations: This does not include labor productivity effects (i.e. physiological reductions of productivity), as there are no robust empirical estimates available for that yet. Unless the realization "LabItr" is used for module 51_internalizeDamages, the damages are not actually part of the optimization, but just enter as a fixed variable reducing output, updated in between iterations.  

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/50_damages/Labor/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/50_damages/Labor/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/50_damages/Labor/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/50_damages/Labor/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/50_damages/Labor/realization.gms
