*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/25_WACC/standard/realization.gms

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/25_WACC/standard/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/25_WACC/standard/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/25_WACC/standard/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/25_WACC/standard/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/25_WACC/standard/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/25_WACC/standard/bounds.gms"
$Ifi "%phase%" == "presolve" $include "./modules/25_WACC/standard/presolve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/25_WACC/standard/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/25_WACC/standard/realization.gms
