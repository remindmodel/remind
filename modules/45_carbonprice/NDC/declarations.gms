*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDC/declarations.gms

Parameter p45_CO2eqwoLU_actual(ttot,all_regi)                   "actual level of regional GHG emissions after previous iteration";
Parameter p45_CO2eqwoLU_goal(ttot,all_regi)                     "regional NDC target level of GHG emissions";
Parameter p45_factorRescaleCO2Tax(ttot,all_regi)                "multiplicative factor to rescale CO2 taxes to achieve the climate targets";
Parameter p45_factorRescaleCO2TaxTrack(iteration,ttot,all_regi) "Track the changes of p45_factorRescaleCO2Tax over the iterations";
Parameter p45_taxCO2eqFirstNDCyear(all_regi)                    "CO2eq tax in p45_firstNDCyear";
Parameter p45_taxCO2eqLastNDCyear(all_regi)                     "CO2eq tax in p45_lastNDCyear";
Scalar    p45_adjustExponent                                    "exponent in tax adjustment process";


*** EOF ./modules/45_carbonprice/NDC/declarations.gms
