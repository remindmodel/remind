*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDC/declarations.gms

Parameter
p45_CO2eqwoLU_actual(ttot,all_regi)                      "actual level of regional GHG emissions after previous iteration [MtCO2eq/yr]"
p45_CO2eqwoLU_goal(ttot,all_regi)                        "regional NDC target level of GHG emissions [MtCO2eq/yr]"
p45_CO2eqwoLU_actual_iter(iteration,ttot,all_regi)       "actual level of regional GHG emissions p45_CO2eqwoLU_actual tracked over iterations [MtCO2eq/yr]"
p45_factorRescaleCO2Tax(ttot,all_regi)                   "multiplicative factor to rescale CO2 taxes to achieve the climate targets [1]"
p45_factorRescaleCO2TaxLtd(ttot,all_regi)                "multiplicative factor to rescale CO2 taxes to achieve the climate targets limited to not-so-fast adaption [1]"
p45_factorRescaleCO2Tax_iter(iteration,ttot,all_regi)    "Track the changes of p45_factorRescaleCO2Tax over the iterations [1]"
p45_factorRescaleCO2TaxLtd_iter(iteration,ttot,all_regi) "Track the changes of p45_factorRescaleCO2TaxLimited over the iterations [1]"
p45_taxCO2eqFirstNDCyear(all_regi)                       "CO2eq tax in p45_firstNDCyear [T$/GtC]"
p45_taxCO2eqLastNDCyear(all_regi)                        "CO2eq tax in p45_lastNDCyear [T$/GtC]"
p45_taxCO2eq_bau(ttot,all_regi)                          "level of CO2 taxes in business as usual run [T$/GtC]"
;

Scalar    p45_adjustExponent                             "exponent in tax adjustment process [1]";


*** EOF ./modules/45_carbonprice/NDC/declarations.gms
