*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/module.gms

*' @title Carbonprice
*'
*' @description
*' The carbonpriceRegi module defines a regional CO2eq tax markup pm_taxCO2eqRegi to satisfy NDC or netZero targets.
*' The carbon price markup is interpolated linearly between the years with policy goals.
*' It can be used jointly with the 45_carbonprice module and adds to the carbonprice calculated there.

*' @authors Oliver Richters

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%carbonpriceRegi%" == "NDC" $include "./modules/46_carbonpriceRegi/NDC/realization.gms"
$Ifi "%carbonpriceRegi%" == "netZero" $include "./modules/46_carbonpriceRegi/netZero/realization.gms"
$Ifi "%carbonpriceRegi%" == "none" $include "./modules/46_carbonpriceRegi/none/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################

*** EOF ./modules/46_carbonpriceRegi/module.gms
