*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/functionalForm/declarations.gms

scalars
s45_taxCO2_startyear                        "CO2 tax provided by cm_taxCO2_startyear converted from $/t CO2eq to T$/GtC"
s45_taxCO2_peakBudgYr                       "CO2 tax provided by cm_taxCO2_peakBudgYr converted from $/t CO2eq to T$/GtC"

$ifThen.taxCO2functionalForm1 "%cm_taxCO2_functionalForm%" == "linear"
s45_taxCO2_historical                       "historical level of CO2 tax converted from $/t CO2eq to T$/GtC"
s45_taxCO2_historicalYr                     "year of s45_taxCO2_historical"
$endIf.taxCO2functionalForm1

s45_regiDiff_gdpThreshold                   "reference value for GDP per capita (1e3 $ PPP 2017) above which carbon price from global anchor trajectory is fully applied"

s45_interpolation_startYr                   "start year of interpolation from p45_taxCO2eq_path_gdx_ref to p45_taxCO2eq_regiDiff"
s45_interpolation_endYr                     "end year of interpolation from p45_taxCO2eq_path_gdx_ref to p45_taxCO2eq_regiDiff"
;

parameters
p45_taxCO2eq_anchor(ttot)                   "global anchor trajectory for regional CO2 price trajectories in T$/GtC = $/kgC"
p45_taxCO2eq_anchor_until2150(ttot)         "global anchor trajectory continued until 2150 - as if there was no change in trajectory after cm_peakBudgYr. Needed if cm_peakBudgYr was shifted right"
p45_taxCO2eq_regiDiff(ttot,all_regi)        "regional differentiated CO2 price trajectories in T$/GtC = $/kgC, used as intermediate step in deriving pm_taxCO2eq from p45_taxCO2eq_anchor"
p45_taxCO2eq_path_gdx_ref(ttot,all_regi)    "CO2 tax trajectories from path_gdx_ref"

p45_gdppcap_PPP(ttot,all_regi)              "GDP per capita (1e3 $ PPP 2017)"
p45_regiDiff_ratio(ttot,all_regi)           "ratio between global anchor and regional differentiated CO2 price trajectories"
p45_regiDiff_startYr(all_regi)              "start year of convergence from regionally differentiated carbon prices to global anchor trajectory"
p45_regiDiff_initialRatio(all_regi)         "inital ratio between global anchor and regional differentiated CO2 price trajectories"
p45_regiDiff_endYr(all_regi)                "end year of regional differentiation, i.e. regional carbon price equal to global anchor trajectory thereafter"
p45_regiDiff_exponent(all_regi)             "regional convergence exponent for ratio between global anchor and regional differentiated CO2 price trajectories"

*** If cm_taxCO2_regiDiff_convergence is not set to scenario, read in data from switch
$ifThen.taxCO2regiDiffConvergence1 "%cm_taxCO2_regiDiff_convergence%" == "scenario"
$else.taxCO2regiDiffConvergence1
p45_regiDiff_convergence_data(ext_regi,ttot)     "input data for regional exponent and convergence year provided by switch cm_taxCO2_regiDiff_convergence"
/ %cm_taxCO2_regiDiff_convergence% /
$endIf.taxCO2regiDiffConvergence1
*** If cm_taxCO2_regiDiff_startyearValue is not set to endogenous, read in data from switch
$ifThen.taxCO2regiDiffStartyearValue1 "%cm_taxCO2_regiDiff_startyearValue%" == "endogenous"
$else.taxCO2regiDiffStartyearValue1
p45_regiDiff_startyearValue(all_regi)       "manually chosen regional carbon price in cm_startyear converted from $/t CO2eq to T$/GtC"
p45_regiDiff_startyearValue_data(ext_regi)  "input data for regional carbon price in start year provided by switch cm_taxCO2_regiDiff_startyearValue"
/ %cm_taxCO2_regiDiff_startyearValue% /
$endIf.taxCO2regiDiffStartyearValue1
;

*** Scalars only used in functionForm/postsolve.gms
scalars
s45_actualbudgetco2                                     "actual level of 2020-2100 cumulated emissions, including all CO2 for last iteration"
s45_actualbudgetco2_last                                "actual level of 2020-2100 cumulated emissions for previous iteration" /0/
s45_factorRescale_taxCO2_exponent_before10              "exponent determining sensitivity    before iteration 10"
s45_factorRescale_taxCO2_exponent_from10                "exponent determining sensitivity of CO2 price adjustment to CO2 budget deviation from iteration 10"
s45_peakBudget                                          "peak CO2 budget as calculated as the maximum of cumulative CO2 emissions, used to check adjustment algorithm [GtC/yr]"
sm_peakBudgYr_check                                     "peak budget year calculated based on maximum of cumulative CO2 emissions, used to check adjustment algorithm  [year]"
sm_peakbudget_diff                                       "difference in cumulative CO2 emissions between cumulative emissions in cm_peakBudgYr and time step of maximum cumulative CO2 emissions [GtCO2]"
;

*** Parameters only used in functionForm/postsolve.gms
parameters 
p45_taxCO2eq_anchor_iter(iteration,ttot)                "save p45_taxCO2eq_anchor in each iteration (before entering functionalForm/postsolve.gms) for debugging"
o45_taxCO2eq_anchor_iterDiff_Itr(iteration)             "track pm_taxCO2eq_anchor_iterationdiff in 2100 over iterations"
p45_taxCO2eq_anchor_iterationdiff_tmp(ttot)             "help parameter for iterative adjustment of taxes"

o45_diff_to_Budg(iteration)                             "Difference between actual CO2 budget and target CO2 budget"
o45_totCO2emi_peakBudgYr(iteration)                     "Total CO2 emissions in the peakBudgYr"
o45_peakBudgYr_Itr(iteration)                           "Year in which the CO2 budget is supposed to peak. Is changed in iterative_target_adjust = 9"
o45_factorRescale_taxCO2_afterPeakBudgYr(iteration)     "Multiplicative factor for rescaling the CO2 price in the year after peakBudgYr - only needed if flip-flopping of peakBudgYr occurs"
o45_delay_increase_peakBudgYear(iteration)              "Counter that tracks if flip-flopping of peakBudgYr happened. Starts an inner loop to try and overcome this"
o45_reached_until2150pricepath(iteration)               "Counter that tracks if the inner loop of increasing the CO2 price AFTER peakBudgYr goes beyond the initial trajectory"
o45_totCO2emi_allYrs(ttot,iteration)                    "Global CO2 emissions over time and iterations. Needed to check the procedure to find the peakBudgYr"
o45_change_totCO2emi_peakBudgYr(iteration)              "Measure for how much the CO2 emissions change around the peakBudgYr"
p45_factorRescale_taxCO2(iteration)                     "Multiplicative factor for rescaling the CO2 price to reach the target"
p45_factorRescale_taxCO2_Funneled(iteration)            "Multiplicative factor for rescaling the CO2 price to reach the target - limited by an iteration-dependent funnel"
o45_pkBudgYr_flipflop(iteration)                        "Counter that tracks if flipfloping of cm_peakBudgYr occured in the last iterations"
p45_peakBudgYr_check(ttot)                              "peak budget year calculated based on maximum of cumulative CO2 emissions, used to check adjustment algorithm  [year]"
;


*** EOF ./modules/45_carbonprice/functionalForm/declarations.gms
