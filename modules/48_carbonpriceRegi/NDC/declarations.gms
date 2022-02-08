*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/48_carbonpriceRegi/NDC/declarations.gms

Parameter
p48_CO2eqwoLU_actual(ttot,all_regi)                      "actual level of regional GHG emissions in previous iteration"
p48_CO2eqwoLU_goal(ttot,all_regi)                        "regional NDC target level of GHG"
p48_factorRescaleCO2Tax(ttot,all_regi)                   "multiplicative factor to rescale CO2 taxes to achieve the climate targets"
p48_factorRescaleCO2TaxLimited(ttot,all_regi)            "multiplicative factor to rescale CO2 taxes to achieve the climate targets limited to not-so-fast adaption"
p48_factorRescaleCO2Tax_iter(iteration,ttot,all_regi)    "Track the changes of p48_factorRescaleCO2Tax over the iterations"
p48_factorRescaleCO2TaxLtd_iter(iteration,ttot,all_regi) "Track the changes of p48_factorRescaleCO2TaxLimited over the iterations"
p48_vm_co2eq_iter(iteration,ttot,all_regi)               "Track the changes of vm_co2eq over the iterations"
p48_taxCO2eqFirstNDCyear(all_regi)                       "CO2eq tax in p48_firstNDCyear"
p48_taxCO2eqLastNDCyear(all_regi)                        "CO2eq tax in p48_lastNDCyear"
p48_vm_CO2eq_2020(all_regi)                              "2020 reference emissions value for normalization of deviation from zero"
p48_taxCO2eq_iter(iteration,ttot,all_regi)               "CO2eq tax non-regi tracked over iterations"
p48_taxCO2eqRegi_iter(iteration,ttot,all_regi)           "CO2eq tax regi tracked over iterations"
p48_taxCO2eqLast(tall,all_regi)                          "general carbon price in last iteration"
;

Scalar    p48_adjustExponent                             "exponent in tax adjustment process";
Scalar    p48_startInIteration                           "first iteration to start adapting pm_taxCO2eqRegi" / 10 /;
Scalar    p48_previousYearInLoop                         "previous year in loop, required for linear interpolation in postsolve";
Scalar    p48_taxPreviousYearInLoop                      "tax of previous year in loop, required for linear interpolation in postsolve";

*** EOF ./modules/48_carbonpriceRegi/NDC/declarations.gms
