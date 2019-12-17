*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/15_climate/box.gms

*' @description 
*' In this realization, concentration, forcing, and temperature values are calculated using a simple model that can be used within the optimization routine.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/15_climate/box/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/15_climate/box/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/15_climate/box/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/15_climate/box/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/15_climate/box/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/15_climate/box/bounds.gms"
$Ifi "%phase%" == "presolve" $include "./modules/15_climate/box/presolve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/15_climate/box/postsolve.gms"
$Ifi "%phase%" == "output" $include "./modules/15_climate/box/output.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/15_climate/box.gms
