*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/netZero/realization.gms

*' @description This realization adds a regional CO2 tax markup to satisfy the net-zero targets.
*' The carbon price markup increases until the net-zero year then decreases toward zero in 2200.
*' This realization best combines with a global CO2 trajectory defined in 45_carbonprice.
*' Regional carbon price markups (pm_taxCO2eqRegi) are adjusted through an iterative feedback   
*' to achieve net-zero emissions targets.
*'  
*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/46_carbonpriceRegi/netZero/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/46_carbonpriceRegi/netZero/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/46_carbonpriceRegi/netZero/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/46_carbonpriceRegi/netZero/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/46_carbonpriceRegi/netZero/realization.gms
