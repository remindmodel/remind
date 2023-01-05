*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/02_welfare/ineqLognormal/realization.gms

*' @description
*' The ineqLognormal realization adds a representation of subregional inequality to the welfare equation. This is determined by the SSP-based Gini projections by Rao et al. and modified by the effects of climate damages and energy expenditure changes due to climate policy. It is also affected by the redistribution of carbon tax revenues, which can be distributed either proportional to income (distributionally neutral) or on an equal-per-capita basis.
*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/02_welfare/ineqLognormal/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/02_welfare/ineqLognormal/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/02_welfare/ineqLognormal/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/02_welfare/ineqLognormal/equations.gms"
$Ifi "%phase%" == "bounds" $include "./modules/02_welfare/ineqLognormal/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/02_welfare/ineqLognormal/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/02_welfare/ineqLognormal/realization.gms
