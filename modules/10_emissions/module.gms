*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/10_emissions/module.gms

*' @title Emissions
*'
*' @description This module calculates and/or collects all GHG emissions. It sums them to
*' relevant aggregate emissions categories used in the policy modules
*' (e.g. 21_tax, 45_cabonprice, 46_carbonpriceRegi, 47_regipol) and for reporting purposes
*' (remind2::reportEmi()). 

*' @authors Felix Schreyer, Anne Merfort, Renato Rodrigues, Gabriel Abrahao

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%emissions%" == "SectorAggregates" $include "./modules/10_emissions/SectorAggregates/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/10_emissions/module.gms
