*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/48_carbonpriceRegi/netZero/declarations.gms

Parameter 
p48_CO2eq_actual(all_regi )        "greenhouse gas emissions in target year"
p48_vm_CO2eq_2020(all_regi)                 "2020 reference emissions value for normalization of deviation from zero"
p48_factorRescaleCO2TaxRegi(all_regi)      "factor of change for additional carbon price"
*pm_taxCO2eqRegi(tall,all_regi)         "additional carbon price to reach net-zero target"
p48_taxCO2eqRegiLast(tall,all_regi)   "additional carbon price to reach net-zero target in last iteration"
p48_taxCO2eqLast(tall,all_regi)        "general carbon price in last iteration"
p48_factorRescaleCO2Tax(all_regi)           "required change of overall tax rate to assure net-zero emission";

*** EOF ./modules/48_carbonpriceRegi/netZero/declarations.gms


