*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/TC/realization.gms

*' @description Tropical cyclone damages based on Krichene et al. (2022). They are growth rate effects (similar to the Burke module) on country level, only for countries affected by tropical cyclones. Coefficients are available for different persistencies (0-8 with 8 being the default) and confidence intervals (based on uncertainty in climate and TC projections)

*' @limitations: Unless the realization "TCitr" is used for module 51_internalizeDamages, the damages are not actually part of the optimization, but just enter as a fixed variable reducing output, updated in between iterations.  

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/50_damages/TC/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/50_damages/TC/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/50_damages/TC/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/50_damages/TC/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/50_damages/TC/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/50_damages/TC/realization.gms
