*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/MOFEX.gms

*' @description This realization is dedicated to the running the standalone version of MOFEX (Model Of Fossil EXtraction), 
*' which minimizes the discounted extraction and trade costs of fossils while balancing trade for each time step. 
*' This is not to be run within a REMIND run but instead through the standalone architecture or in a soft-linked iteration 
*' with REMIND (not yet implemented)

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/31_fossil/MOFEX/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/31_fossil/MOFEX/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/31_fossil/MOFEX/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/31_fossil/MOFEX/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/31_fossil/MOFEX/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/31_fossil/MOFEX/bounds.gms"
$Ifi "%phase%" == "solve" $include "./modules/31_fossil/MOFEX/solve.gms"
$Ifi "%phase%" == "output" $include "./modules/31_fossil/MOFEX/output.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/31_fossil/MOFEX.gms
