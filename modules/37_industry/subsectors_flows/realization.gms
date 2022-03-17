*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/realization.gms

*' @description subsectors models industry subsectors explicitly with individual
*' CES nests for cement, chemicals, steel, and otherInd production.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/37_industry/subsectors_flows/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/37_industry/subsectors_flows/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/37_industry/subsectors_flows/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/37_industry/subsectors_flows/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/37_industry/subsectors_flows/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/37_industry/subsectors_flows/bounds.gms"
$Ifi "%phase%" == "presolve" $include "./modules/37_industry/subsectors_flows/presolve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/37_industry/subsectors_flows/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/37_industry/subsectors/realization.gms

