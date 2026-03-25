*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/netZero/declarations.gms

Parameter
p46_emi_targetYr(all_regi)                     "Greenhouse gas or CO2 emissions in target year [MtCO2eq/yr]"
p46_emi_targetYr_iter(iteration,ttot,all_regi) "Track the changes of p46_emi_targetYr over the iterations [MtCO2eq/yr]"
p46_emi_offset(all_regi)                       "Allowed offset emissions in net-zero year [MtCO2eq/yr]"
p46_emi_refYr(all_regi)                        "2025 reference emissions value for normalization of deviation from zero [MtCO2eq/yr]"
p46_emi_refRun(all_regi)                       "Emissions in reference BAU run in the target year [MtCO2eq/yr]"
p46_refRun_co2eq(ttot,all_regi)                "Container for input_bau values of co2eq"
p46_refRun_emiFgas(ttot,all_regi,all_enty)     "Container for input_bau values of emiFgas"
p46_refRun_emiTe(ttot,all_regi,all_enty)       "Container for input_bau values of emiTe"
p46_refRun_emiMac(ttot,all_regi,all_enty)      "Container for input_bau values of emiMac"
p46_refRun_emiCdr(ttot,all_regi,all_enty)      "Container for input_bau values of emiCdr"

p46_taxCO2eqRegiPeak(all_regi)                 "Peak value of the additional regional CO2 tax in target year, updated by the algorithm in module 46 [T$/GtC]"
pm_taxCO2eqRegi(ttot,all_regi)                 "Additional markup carbon in 46_carbonpriceRegi module to reach net-zero targets [T$/GtC]. Multiply by 272 to convert to $/tCO2."
pm_taxCO2eqSum(ttot,all_regi)                  "Total CO2 price including general trajectory (pm_taxCO2eq), regional markup (pm_taxCO2eqRegi) and social cost of carbon (pm_taxCO2eqSCC) [T$/GtC]. Multiply by 272 to convert to $/tCO2."
p46_taxCO2eqRegi_iter(iteration,ttot,all_regi) "Track regional CO2eq tax over iterations [T$/GtC]"
p46_taxCO2eq_iter(iteration,ttot,all_regi)     "Track general CO2eq tax over iterations [T$/GtC]"

p46_targetDeviation(all_regi)                  "Deviation from net-zero target rescaled to reference emission [1]"
p46_factorRescaleCO2Tax(all_regi)              "Required change factor of overall tax rate to assure net-zero emission [1]"
p46_iterDamping	                               "Lower bound on the price rescaling to avoid oscillations and favour convergence, between 0.25 and 1"
p46_targetCoverage(all_regi)                   "Share of the region that is covered by a net-zero target [1]"
;

Scalar  
p46_startInIteration                           "First iteration to start adapting pm_taxCO2eqRegi [1]" / 10 /
;

*** EOF ./modules/46_carbonpriceRegi/netZero/declarations.gms


