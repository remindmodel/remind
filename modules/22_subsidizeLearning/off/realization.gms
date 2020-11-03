*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/22_subsidizeLearning/off.gms

*' @description
*' There is no subsidizing of learning technologies (fixed to zero). Under this realization we get different results from Negishi and Nash solutions.
*' Wheras in the Negishi approach, the social planner internalizes the external effects of investments into learning technologies (co-operative solution),
*' under the Nash approach, the regional actors do not take the benefits for other regions into account when they invest (non-cooperative solution).
*' Still, learning spillovers (based on cumulated installed capacities) occur. 


*' @limitations
*' Within the non-cooperative solution, there is full internalization of learning spillover over times.
*' Furthermore, due to the size of regions, also learning spillovers across countries are partly internalized.


*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/22_subsidizeLearning/off/declarations.gms"
$Ifi "%phase%" == "bounds" $include "./modules/22_subsidizeLearning/off/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/22_subsidizeLearning/off/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/22_subsidizeLearning/off.gms
