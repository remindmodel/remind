*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/22_subsidizeLearning/22_subsidizeLearning.gms
*' @title Subsidies on learning technologies
*'
*' @description
*' The module computes the level of subsidies for building capacities of learning technologies.
*' Learning spillovers are captured. Yet, based on the level of subsidies, the social benefits of investing into
*' learning technologies are internalized (co-operative solution) or not (non-cooperative solution w.r.t. learning spillovers)
*'
*' @authors Anselm Schultes, Marian Leimbach


*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%subsidizeLearning%" == "globallyOptimal" $include "./modules/22_subsidizeLearning/globallyOptimal/realization.gms"
$Ifi "%subsidizeLearning%" == "off" $include "./modules/22_subsidizeLearning/off/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/22_subsidizeLearning/22_subsidizeLearning.gms
