*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/netZero/declarations.gms

Parameter 
p46_emi_actual(all_regi)                            "greenhouse gas or CO2 emissions in target year [MtCO2eq/yr]"
p46_emi_2020(all_regi)                              "2020 reference emissions value for normalization of deviation from zero [MtCO2eq/yr]"
p46_factorRescaleCO2TaxRegi(all_regi)               "factor of change for additional carbon price [1]"
p46_taxCO2eqRegiLast(tall,all_regi)                 "additional carbon price to reach net-zero target in last iteration [T$/GtC]"
p46_taxCO2eqLast(tall,all_regi)                     "general carbon price in last iteration [T$/GtC]"
p46_factorRescaleCO2Tax(all_regi)                   "required change of overall tax rate to assure net-zero emission [1]"
p46_taxCO2eq_iter(iteration,ttot,all_regi)          "CO2eq tax non-regi tracked over iterations [T$/GtC]"
p46_taxCO2eqRegi_iter(iteration,ttot,all_regi)      "CO2eq tax regi tracked over iterations [T$/GtC]"
p46_factorRescaleCO2TaxLtd_iter(iteration,all_regi) "Track the changes of p46_factorRescaleCO2TaxLimited over the iterations [1]"
p46_emi_actual_iter(iteration,ttot,all_regi)        "Track the changes of p46_emi_actual over the iterations [MtCO2eq/yr]"
p46_offset(all_regi)                                "allowed emissions in netZero year [MtCO2eq/yr]"
p46_ref_co2eq (ttot,all_regi)                       "emissions in reference run"
pm_taxCO2eqRegi(tall,all_regi)                      "Additional regional CO2 tax path calulated in in 46_carbonpriceRegi module to reach regional emissions targets [T$/GtC]. To get $/tCO2, multiply with 272 = 1 / sm_DptCO2_2_TDpGtC"
pm_taxCO2eqSum(tall,all_regi)                       "sum of pm_taxCO2eq, pm_taxCO2eqRegi, pm_taxCO2eqSCC [T$/GtC]. To get $/tCO2, multiply with 272 = 1 / sm_DptCO2_2_TDpGtC"
;

Scalar p46_zeroYear                                 "between the netZero goal and this scalar, pm_taxCO2eqRegi linearly drops to zero [year]"
Scalar p46_startInIteration                         "first iteration to start adapting pm_taxCO2eqRegi [1]" / 10 /;

*** EOF ./modules/46_carbonpriceRegi/netZero/declarations.gms


