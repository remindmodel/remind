*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDC/declarations.gms

Parameter p45_actual_co2eq_woLU_regi(ttot,all_regi)                "actual level of regional 2020/2025/2030 GHG emissions in previous iteration";
Parameter p45_ref_co2eq_woLU_regi(ttot,all_regi)                   "regional NDC target level of GHG - with different temporal meanings depending on NDC target year";
Parameter p45_factorRescaleCO2Tax(ttot,all_regi)                   "multiplicative factor to rescale CO2 taxes to achieve the climate targets";
Parameter p45_factorRescaleCO2TaxTrack(iteration,ttot,all_regi)    "Track the changes of p45_factorRescaleCO2Tax over the iterations";
Parameter p45_taxCO2eq_first_NDC_year(all_regi)                    "CO2eq tax in p45_first_NDC_year";
Parameter p45_taxCO2eq_last_NDC_year(all_regi)                     "CO2eq tax in p45_last_NDC_year";
Scalar    p45_adjust_exponent                                      "exponent in tax adjustment process";


*** EOF ./modules/45_carbonprice/NDC/declarations.gms
