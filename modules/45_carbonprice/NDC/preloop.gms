*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDC/preloop.gms

***CB* special case SSA: maximum carbon price (after adjustment below) at 7.5$ in 2020, 30 in 2025, 45 in 2030, to reflect low energy productivity of region, and avoid high losses
pm_taxCO2eq(t,regi)$(sameas(t, "2020") and sameas(regi,"SSA")) = 15 * sm_DptCO2_2_TDpGtC;

*** first calculate tax path until last NDC target year - linear increase
pm_taxCO2eq(t,regi)$(t.val gt 2016 AND t.val le p45_lastNDCyear(regi)) = pm_taxCO2eq("2020",regi)*(t.val-2015)/5;

*** convergence scheme after the last NDC target year: exponential increase with 1.25% AND regional convergence until p45_taxCO2eqConvergenceYear
p45_taxCO2eqLastNDCyear(regi) = smax(t$(t.val = p45_lastNDCyear(regi)), pm_taxCO2eq(t,regi));

pm_taxCO2eq(t,regi)$(t.val gt p45_lastNDCyear(regi))
   = (  !! regional, weight going from 1 in last NDC target year to 0 in 2100
        p45_taxCO2eqLastNDCyear(regi) * p45_taxCO2eqYearlyIncrease**(t.val-p45_lastNDCyear(regi)) * (max(p45_taxCO2eqConvergenceYear,t.val) - t.val)
        !! global, weight going from 0 in NDC target year to 1 in and after 2100
      + p45_taxCO2eqGlobal2030          * p45_taxCO2eqYearlyIncrease**(t.val-2030)                    * (min(p45_taxCO2eqConvergenceYear,t.val) - p45_lastNDCyear(regi))
      )/(p45_taxCO2eqConvergenceYear - p45_lastNDCyear(regi));

display pm_taxCO2eq;

***as a minimum, have linear price increase starting from 1$ in 2030
pm_taxCO2eq(t,regi)$(t.val gt p45_lastNDCyear(regi)) = max(pm_taxCO2eq(t,regi),1*sm_DptCO2_2_TDpGtC * (1+(t.val-2030)*9/7));

*** new 2020 carbon price definition: weighted average of 2015 and 2025, with triple weight for 2015 (which is zero for all non-eu regions).
pm_taxCO2eq(t,regi)$sameas(t, "2020") = (3*pm_taxCO2eq("2015",regi)+pm_taxCO2eq("2025",regi))/4;

display pm_taxCO2eq;

*#' @equations 
*#'  calculate level of emission target that it should converge to, composed of:
*#'  emission target relative to 2005 emissions (factor_targetyear) for part of region with NDC target
*#'  baseline for the rest of the countries
p45_CO2eqwoLU_goal(p45_NDCyearSet(t,regi)) =
          p45_2005shareTarget(t,regi)     * p45_BAU_reg_emi_wo_LU_bunkers("2005",regi) * p45_factorTargetyear(t,regi)    !! share with NDC target
        + (1-p45_2005shareTarget(t,regi)) * p45_BAU_reg_emi_wo_LU_bunkers(t,regi);            !! baseline for share of countries without NDC target

display pm_taxCO2eq,p45_CO2eqwoLU_goal;
*** EOF ./modules/45_carbonprice/NDC/preloop.gms
