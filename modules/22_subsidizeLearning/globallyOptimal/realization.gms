*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/22_subsidizeLearning/globallyOptimal.gms

*' @description
*' This realization is meaningful in order to find the global optimal solution or co-operative solution w.r.t. learning spillovers under the Nash algorithm.
*' For that purpose the optimal subsidy for investing in capacities of learning technologies is computed. The level of optimal subsidy is computed based
*' on the marginal benefits of learning spillovers across all regions (Schultes et al., 2019). Based on this subsidy, regional actors invest in the same way into
*' learning technologies as a global social planner would do, internalizing all external leearning spillover effects. 


*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/22_subsidizeLearning/globallyOptimal/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/22_subsidizeLearning/globallyOptimal/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/22_subsidizeLearning/globallyOptimal/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/22_subsidizeLearning/globallyOptimal/equations.gms"
$Ifi "%phase%" == "bounds" $include "./modules/22_subsidizeLearning/globallyOptimal/bounds.gms"
$Ifi "%phase%" == "presolve" $include "./modules/22_subsidizeLearning/globallyOptimal/presolve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/22_subsidizeLearning/globallyOptimal/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/22_subsidizeLearning/globallyOptimal.gms
