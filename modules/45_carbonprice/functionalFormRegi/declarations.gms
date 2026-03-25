*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/functionalFormRegi/declarations.gms

scalars
s45_taxCO2_startyear                        "CO2 tax provided by cm_taxCO2_startyear converted from $/t CO2eq to T$/GtC"
s45_taxCO2_peakBudgYr                       "CO2 tax provided by cm_taxCO2_peakBudgYr converted from $/t CO2eq to T$/GtC"
s45_YearBeforeStartYear                     "The REMIND year before cm_startyear"

$ifThen.taxCO2functionalForm1 "%cm_taxCO2_functionalForm%" == "linear"
s45_taxCO2_historical                       "historical level of CO2 tax converted from $/t CO2eq to T$/GtC"
s45_taxCO2_historicalYr                     "year of s45_taxCO2_historical"
$endIf.taxCO2functionalForm1
;

parameters
p45_taxCO2eq_anchor(ttot)                   "global anchor trajectory for regional CO2 price trajectories in T$/GtC = $/kgC"
p45_taxCO2eq_anchor_until2150(ttot)         "global anchor trajectory continued until 2150 - as if there was no change in trajectory after cm_peakBudgYr. Needed if cm_peakBudgYr was shifted right"
p45_taxCO2eq_regiDiff(ttot,all_regi)        "regional differentiated CO2 price trajectories in T$/GtC = $/kgC, used as intermediate step in deriving pm_taxCO2eq from p45_taxCO2eq_anchor"
p45_taxCO2eq_path_gdx_ref(ttot,all_regi)    "CO2 tax trajectories from path_gdx_ref"

p45_regiDiff_ratio(ttot,all_regi)           "ratio between global anchor and regional differentiated CO2 price trajectories"
p45_regiDiff_startYr(all_regi)              "start year of convergence from regionally differentiated carbon prices to global anchor trajectory"
p45_regiDiff_initialRatio(all_regi)         "inital ratio between global anchor and regional differentiated CO2 price trajectories"
p45_regiDiff_endYr(all_regi)                "end year of regional differentiation, i.e. regional carbon price equal to global anchor trajectory thereafter"
p45_regiDiff_exponent(all_regi)             "regional convergence exponent for ratio between global anchor and regional differentiated CO2 price trajectories"

p45_taxCO2eq_path_gdx_input(ttot,all_regi)    "CO2 tax trajectories from path_gdx"
p45_taxCO2refYear(all_regi)                      "CO2 tax in reference year for derivation of the carbon price trajectory in the first iteration, can be in last fixed time step, or peak carbon price year depending on the shape"

*** If there is a regional budget, read regional carbon budget from switch and set additionally needed parameters
p45_budgetCO2from2020Regi(all_regi)                      "regional carbon budget (Gt CO2)"
p45_budgetCO2from2020RegiShare(all_regi)                 "share of region in global carbon budget" /%cm_budgetCO2from2020RegiShare%/
p45_actualbudgetco2Regi_2100(all_regi)                   "regional - actual level of 2020-2100 cumulated emissions, including all CO2 for last iteration"
p45_actualbudgetco2Regi_2100_iter(iteration,all_regi)    "regional - actual level of 2020-2100 cumulated emissions, including all CO2 for last iteration"
p45_factorRescale_taxCO2Regi(iteration,all_regi)         "regional - Multiplicative factor for rescaling the CO2 price to reach the target"
p45_factorRescale_taxCO2Regi_Funneled(iteration, all_regi)  "regional - Multiplicative factor for rescaling the CO2 price to reach the target - Funnelled (static)"
pm_factorRescale_taxCO2Regi_Funneled2(iteration, all_regi) "regional - Multiplicative factor for rescaling the CO2 price to reach the target - Funnelled (interactive, incl. adjustments based on last iterations)"
p45_factorRescale_taxCO2Regi_Final(iteration, all_regi)     "regional - Multiplicative factor for rescaling the CO2 price to reach the target - Funnelled, may include up/downward iteration differentiation"
p45_taxCO2eq_anchorRegi(ttot,all_regi)                   "regional anchor trajectory for regional CO2 price trajectories in T$/GtC = $/kgC"
p45_taxCO2eq_anchorRegi_iter(ttot, all_regi, iteration)  "regional anchor trajectory for regional CO2 price trajectories in T$/GtC = $/kgC across iterations"
p45_taxCO2eq_anchorRegi_until2150(ttot,all_regi)         "save the p45_taxCO2eq_anchorRegi derived in datainput.gms"
p45_temp_anchor(ttot,all_regi)                           "regionally shifted anchor for all iterations (helper, may be removed)"
pm_budgetDeviation(all_regi)                             "deviations from regional targets"  
p45_budgetDeviation_iter(iteration, all_regi)            "deviations from regional targets across iterations"  
pm_regionalBudget_absDevTol(all_regi)                    "tolerance of deviation from regional targets in absolute terms"

p45_TaxBudgetSlopeCurrent(all_regi)                      "regional carbon price change/regional carbon budget change - from the last 2 iterations"
p45_TaxBudgetSlopeCurrent_iter(iteration, all_regi)      "regional carbon price change/regional carbon budget change - from the last 2 iterations, for each iteration. 0 when no carbon price change"
p45_TaxBudgetSlopeBest(all_regi)                         "last available regional carbon price change/regional carbon budget change that is negative"
p45_TaxBudgetSlopeBest_iter(iteration, all_regi)         "last available regional carbon price change/regional carbon budget change that is negative for each iteration"
p45_CarbonPriceSlope(all_regi)                           "when carbon price slope is regionally adjusted: increase of carbon price per year"
p45_CarbonPriceSlope_iter(iteration,all_regi)            "when carbon price slope is regionally adjusted: increase of carbon price per year for each iteration"

p45_FunnelUpper(iteration)                               "upper bound on regional carbon price funnel"
;

*** EOF ./modules/45_carbonprice/functionalFormRegi/declarations.gms
