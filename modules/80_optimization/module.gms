*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/80_optimization.gms

*' @title Optimization
*'
*' @description The optimization module gives the opportunity to choose different solution algorithms. 
*'
*'
*' @authors Anastasis Giannousakis, Marian Leimbach, Lavinia Baumstark, Gunnar Luderer, Anselm Schultes 

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%optimization%" == "nash" $include "./modules/80_optimization/nash/realization.gms"
$Ifi "%optimization%" == "negishi" $include "./modules/80_optimization/negishi/realization.gms"
$Ifi "%optimization%" == "testOneRegi" $include "./modules/80_optimization/testOneRegi/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/80_optimization/80_optimization.gms
