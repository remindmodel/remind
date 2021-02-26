*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/81_codePerformance/on.gms


*' @description BAU, tax30, and tax150 runs are set in a loop of 30 runs in total.
*' The realization needs the realization "exogenous" of the 45_carbonprice module
    
*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/81_codePerformance/on/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/81_codePerformance/on/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/81_codePerformance/on/datainput.gms"
$Ifi "%phase%" == "presolve" $include "./modules/81_codePerformance/on/presolve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/81_codePerformance/on/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/81_codePerformance/on.gms
