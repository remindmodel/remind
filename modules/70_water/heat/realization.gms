*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/70_water/heat/realization.gms

*' @description Exogenous water demand is calculated based on data on water demand coefficients and cooling shares. 
*' Vintage structure in combination with time dependent cooling shares as vintages and efficiency factors are also considered.
*' Demand is a function of excess heat as opposed to electricity output.
*' @limitations Water demand is calculated in a post-processing of REMIND and not part of the optimization.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/70_water/heat/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/70_water/heat/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/70_water/heat/datainput.gms"
$Ifi "%phase%" == "output" $include "./modules/70_water/heat/output.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/70_water/heat/realization.gms
