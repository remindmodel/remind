*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/none/declarations.gms

Parameter 
pm_taxCO2eqRegi(ttot,all_regi)                      "Additional regional CO2 tax path calulated in in 46_carbonpriceRegi module to reach regional emissions targets [T$/GtC]. To get $/tCO2, multiply with 272 = 1 / sm_DptCO2_2_TDpGtC"
pm_taxCO2eqSum(ttot,all_regi)                       "sum of pm_taxCO2eq, pm_taxCO2eqRegi, pm_taxCO2eqSCC [T$/GtC]. To get $/tCO2, multiply with 272 = 1 / sm_DptCO2_2_TDpGtC"
;

*** EOF ./modules/46_carbonpriceRegi/none/declarations.gms


