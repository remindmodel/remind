*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/70_water/exogenous.gms

*' @description Exogenous water demand is calculated based on data on water demand coefficients and cooling shares.
*' @limitations Water demand is calculated in a post-processing of REMIND and not part of the optimization.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/70_water/exogenous/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/70_water/exogenous/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/70_water/exogenous/datainput.gms"
$Ifi "%phase%" == "output" $include "./modules/70_water/exogenous/output.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/70_water/exogenous.gms
