*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/diffPriceSameCost.gms

*#' @description This realization implements carbon price trajectories compatible with respect to a global target but with equal regional relative (NPV) mitigation cost. 


*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/45_carbonprice/diffPriceSameCost/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/45_carbonprice/diffPriceSameCost/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/45_carbonprice/diffPriceSameCost/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/45_carbonprice/diffPriceSameCost.gms
