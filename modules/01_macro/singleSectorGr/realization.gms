*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/01_macro/singleSectorGr.gms

*' @description The singleSectorGr realization corresponds to a neo-classical, single 
*' sector growth model.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/01_macro/singleSectorGr/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/01_macro/singleSectorGr/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/01_macro/singleSectorGr/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/01_macro/singleSectorGr/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/01_macro/singleSectorGr/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/01_macro/singleSectorGr/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/01_macro/singleSectorGr/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/01_macro/singleSectorGr.gms
