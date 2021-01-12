*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/nash.gms

*' @description
*' Unlike in Negishi-mode, each region forms its own optimization problem in Nash mode.
*' Regions trade on goods and resource markets, but market-clearing conditions are not part of the optimization itself.
*' Instead, the Nash-algorithm iteratively computes solutions for all regions including their trade patterns, and adjusts prices such that the surplus on global markets vanishes.
*' Initial values for trade patterns, prices etc. are taken from the gdx (input.gdx).
*'
*' Potential benefits of a Nash-solution are a massive reduction in run-time (convergence within a few hours), and more flexibility in treating inter-regional externalities.
*' Learning-by-doing technologies (learnte) are included by default and cause an inter-regional spill-over. This causes a welfare difference between the solution in Nash- and Negishi-mode.
*' In Nash-mode, a subsidy on the investment cost of learning technologies can be used to internalize this spill-over externality. This subsidy is implemented in the module 22_subsidizeLearning.
*'
*' Without internalizing the learning-by-doing spill-over due to the global learning curve, Nash and Negishi solution differ. This is the case in the default setting of the corresponding module:
*' cfg$gms$subsidizeLearning <- "off"
*' In Nash-mode, the subsidy internalizing this externality can be calculated.
*' When activated by cfg$gms$subsidizeLearning <- "globallyOptimal" the Nash solution should be equivalent to the Negishi solution.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/80_optimization/nash/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/80_optimization/nash/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/80_optimization/nash/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/80_optimization/nash/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/80_optimization/nash/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/80_optimization/nash/bounds.gms"
$Ifi "%phase%" == "presolve" $include "./modules/80_optimization/nash/presolve.gms"
$Ifi "%phase%" == "solve" $include "./modules/80_optimization/nash/solve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/80_optimization/nash/postsolve.gms"
$Ifi "%phase%" == "output" $include "./modules/80_optimization/nash/output.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/80_optimization/nash.gms
