*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/testOneRegi.gms

*' @description This is a reduced model version, only containing one region.
*' It is equivalent to the Nash realization with just one region. Prices of resources and goods are exogenously fixed to the values taken from the gdx.
*'
*' Run time is some minutes.
*'
*' @limitations This realization is only useful for testing purposes or for regions with no influence on the global prices of traded goods.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/80_optimization/testOneRegi/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/80_optimization/testOneRegi/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/80_optimization/testOneRegi/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/80_optimization/testOneRegi/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/80_optimization/testOneRegi/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/80_optimization/testOneRegi/bounds.gms"
$Ifi "%phase%" == "solve" $include "./modules/80_optimization/testOneRegi/solve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/80_optimization/testOneRegi/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/80_optimization/testOneRegi.gms
