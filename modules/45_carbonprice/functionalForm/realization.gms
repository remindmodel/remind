*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/functionalForm/realization.gms

*' @description: Carbon price trajectory follows a prescribed functional form (linear/exponential) - either until peak year or until end-of-century - 
*'               and can be endogenously adjusted to meet CO2 budget targets  - either peak or end-of-century - that are formulated in terms of total cumulated CO2 emissions from 2020 (cm_budgetCO2from2020).
*'               Flexible choices for regional carbon price differentiation and near-term adjustments.

*' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*'  The realization uses a global anchor trajectory based on which the regional carbon price trajectories are defined.
*'  Part I (Global anchor trajectory): The functional form (linear/exponential) of the global anchor trajectory is chosen via cm_taxCO2_functionalForm. 
*'                                     The (initial) global anchor carbon price in cm_startyear is chosen via cm_taxCO2_startyear. Alternatively, the (initial) global anchor carbon price in cm_peakBudgYr is chosen via cm_taxCO2_peakBudgYr.
*'                                     This value is endogenously adjusted to meet CO2 budget targets if cm_iterative_target_adj is set to 5, 7 or 9.
*'                                     (linear):      The linear curve is determined by the two points (cm_taxCO2_historicalYr, cm_taxCO2_historical) and (cm_startyear, cm_taxCO2_startyear). 
*'                                                    By default, cm_taxCO2_historicalYr is the last timestep before cm_startyear, and cm_taxCO2_historical is the carbon price in that timestep in the reference run (path_gdx_ref) - computed as the maximum of pm_taxCO2eq over all regions.
*'                                     (exponential): The exponential curve is determined by exponential growth rate (cm_taxCO2_expGrowth).
*'  Part II (Post-peak behaviour): The global anchor trajectory can be adjusted after reaching the peak of global CO2 emissions in cm_peakBudgYr.
*'                                 The (initial) choice of cm_peakBudgYr is endogenously adjusted if cm_iterative_target_adj is set to 7 or 9.
*'                                     (with iterative_target_adj = 0): after cm_peakBudgYr, the global anchor trajectory increases linearly with fixed annual increase given by cm_taxCO2_IncAfterPeakBudgYr (default = 0, i.e. constant),
*'                                                                      set cm_peakBudgYr = 2100 to avoid adjustment
*'                                     (with iterative_target_adj = 5): no adjustment to the functional form after cm_peakBudgYr since end-of-century CO2 budget target is formulated
*'                                     (with iterative_target_adj = 7): after cm_peakBudgYr, the global anchor trajectory is adjusted so that global net CO2 emissions stay close to zero
*'                                     (with iterative_target_adj = 9): after cm_peakBudgYr, the global anchor trajectory increases linearly with fixed annual increase given by cm_taxCO2_IncAfterPeakBudgYr (default = 0, i.e. constant)
*'  Part III (Regional differentiation): Regional carbon price differentiation relative to global anchor trajectory is chosen via cm_taxCO2_regiDiff.
*'                                     (none): No regional differentiation, i.e. globally uniform carbon pricing
*'                                     (ScenarioMIP2035): Carbon price differentiation with convergence year 2035 - used in ScenarioMIP - that takes carbon prices from path_gdx_ref or cm_taxCO2_regiDiff_startyearValue as starting point and assumes regionally differentiated speed of convergence to global anchor trajectory
*'                                     (ScenarioMIP2050): Carbon price differentiation with convergence year 2050 - used in ScenarioMIP - that takes carbon prices from path_gdx_ref or cm_taxCO2_regiDiff_startyearValue as starting point and assumes regionally differentiated speed of convergence to global anchor trajectory
*'                                     (ScenarioMIP2070): Carbon price differentiation with convergence year 2070 - used in ScenarioMIP - that takes carbon prices from path_gdx_ref or cm_taxCO2_regiDiff_startyearValue as starting point and assumes regionally differentiated speed of convergence to global anchor trajectory
*'                                     (ScenarioMIP2100): Carbon price differentiation with convergence year 2100 - used in ScenarioMIP - that takes carbon prices from path_gdx_ref or cm_taxCO2_regiDiff_startyearValue as starting point and assumes regionally differentiated speed of convergence to global anchor trajectory
*'                                     (initialSpread10): Maximal initial spread of carbon prices in 2030 between OECD regions and poorest region is equal to 10. Initial spread for each region determined based on GDP per capita (PPP) in 2030. By default, carbon prices converge using quadratic phase-in until 2050. Convergence scheme can be adjusted with cm_taxCO2_regiDiff_convergence.
*'                                     (initialSpread20): Maximal initial spread of carbon prices in 2030 between OECD regions and poorest region is equal to 20. Initial spread for each region determined based on GDP per capita (PPP) in 2030. By default, carbon prices converge using quadratic phase-in until 2070. Convergence scheme can be adjusted with cm_taxCO2_regiDiff_convergence.
*'                                     (gdpSpread):       Regional differentiation based on GDP per capita (PPP) throughout the century. Uses current GDP per capita (PPP) of OECD countries - around 50'000 US$2017 - as threshold for application of full carbon price.
*'                                     (manual):          Enables manual specification of regional carbon price differentiation based on cm_taxCO2_regiDiff_convergence and cm_taxCO2_regiDiff_startyearValue
*'  Part IV (Interpolation from path_gdx_ref): To smoothen a potential jump of carbon prices in cm_startyear, an interpolation between (a) the carbon prices before cm_startyear provided by path_gdx_ref and (b) the carbon prices from cm_startyear onward defined by parts I-III can be chosen via cm_taxCO2_interpolation
*'                                     In addition, the carbon prices provided by path_gdx_ref are used as lower bound if switch cm_taxCO2_lowerBound_path_gdx_ref is on.
*'                                     (off): no interpolation, i.e. (b) is used from cm_startyear onward. This must be chosen if regional carbon prices are manually set via cm_taxCO2_regiDiff_startyearValue.
*'                                     (one_step): linear interpolation within 10 years between (a) and (b). For example, if cm_startyear = 2030, it uses (a) until 2025, the average of (a) and (b) in 2030, and (b) from 2035.
*'                                     (two_steps): linear interpolation within 15 years between (a) and (b). For example, if cm_startyear = 2030, it uses (a) until 2025, weighted averages of (a) and (b) in 2030 and 2035, and (b) from 2040.
*' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/45_carbonprice/functionalForm/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/45_carbonprice/functionalForm/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/45_carbonprice/functionalForm/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/45_carbonprice/functionalForm/realization.gms
