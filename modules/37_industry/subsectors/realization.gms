*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors.gms

*' @description Under development.  Do not use.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/37_industry/subsectors/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/37_industry/subsectors/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/37_industry/subsectors/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/37_industry/subsectors/equations.gms"
$Ifi "%phase%" == "bounds" $include "./modules/37_industry/subsectors/bounds.gms"
$Ifi "%phase%" == "presolve" $include "./modules/37_industry/subsectors/presolve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/37_industry/subsectors/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/37_industry/subsectors.gms

