*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/grades2poly.gms

*' @description This realization parametrizes fossil extraction cost curves into 3rd-order polynomials for each fuel (oil, gas and coal) in each region.
*' Input data are taken from REMIND runs with the timeDepGrades fossil realization under various fossil fuel availability assumptions.
*' This approximation of the original cost-grade-based extraction algorithm greatly reduces model runtime.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/31_fossil/grades2poly/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/31_fossil/grades2poly/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/31_fossil/grades2poly/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/31_fossil/grades2poly/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/31_fossil/grades2poly/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/31_fossil/grades2poly/bounds.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/31_fossil/grades2poly.gms
