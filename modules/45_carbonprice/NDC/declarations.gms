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
p45_taxCO2eq_bau(ttot,all_regi)                          "level of CO2 taxes in business as usual run [T$/GtC]"
pm_NDCEmiTargetDeviation(ttot,all_regi)                  "deviation of REMIND emissions to NDC target emissions in last iteration normalized to NDC target emissions [0-1]"
$ifthen "%cm_NDC_delay%" == "prisma"
p45_delay(all_regi)                                      "delay of NDC targets defined per region"
$endif
$ifthen not "%cm_NDC_CO2PriceLimit%" == "off"
p45_CO2PriceLimitNDC(ttot,all_regi)                       "Upper limit of CO2 price in NDC realization, read from switch cm_NDC_CO2PriceLimit [$/tCO2]" / %cm_NDC_CO2PriceLimit% /
$endif
;

Scalar    p45_adjustExponent                             "exponent in tax adjustment process [1]";


*** EOF ./modules/45_carbonprice/NDC/declarations.gms
