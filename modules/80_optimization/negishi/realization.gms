*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/negishi.gms

*' @description
*' In Negishi mode, all regions forms a big optimization problem, as opposed to separate optimizations in Nash mode.
*' Regions trade on goods and resource markets, and market-clearing conditions are also part of the optimization.
*' The Negishi algorithm iteratively computes solutions for the whole globe including regional trade patterns, and adjusts
*' the so-called Negishi weights until a Pareto optimal solution is found. Negishi weights are the coefficients of regional utilities in their sum
*' that forms the utility function of REMIND and are computed via an intertemporal trade balance.
*'
*' Initial values for the Negishi weights are taken from the gdx (input.gdx).
*'
*' @limitations This realization is computationally very expensive. Unless a very specific problem has to be solved, using the Nash realization will
*' deliver the same result in a fraction of the time.



*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/80_optimization/negishi/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/80_optimization/negishi/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/80_optimization/negishi/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/80_optimization/negishi/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/80_optimization/negishi/bounds.gms"
$Ifi "%phase%" == "solve" $include "./modules/80_optimization/negishi/solve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/80_optimization/negishi/postsolve.gms"
$Ifi "%phase%" == "output" $include "./modules/80_optimization/negishi/output.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/80_optimization/negishi.gms
