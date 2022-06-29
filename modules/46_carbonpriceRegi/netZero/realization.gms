*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/netZero/realization.gms

*' @description This realization adds a regional CO2 tax markup to satisfy the net-zero targets
*' the carbon price follows a triangular trajectory, increasing until the net-zero year and going back to zero in 2100.
*' this realization should best be combined with a global CO2 trajectory defined in 45_carbonprice

*' @limitations Only regions where all countries have the same target are considered
*' If you require this partial targets, use 46/NDC, but this has issues differentiating CO2 and GHG goals

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/46_carbonpriceRegi/netZero/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/46_carbonpriceRegi/netZero/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/46_carbonpriceRegi/netZero/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/46_carbonpriceRegi/netZero/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/46_carbonpriceRegi/netZero/realization.gms
