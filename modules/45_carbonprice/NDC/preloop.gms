*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDC/preloop.gms

*** first calculate tax path until last NDC target year - linear increase
pm_taxCO2eq(t,regi)$(t.val gt 2021 AND t.val le p45_lastNDCyear(regi)) = pm_taxCO2eq("2020",regi)*(t.val-2015)/5;

*** convergence scheme after the last NDC target year: exponential increase with 1.25% AND regional convergence until p45_taxCO2eqConvergenceYear
p45_taxCO2eqLastNDCyear(regi) = smax(t$(t.val = p45_lastNDCyear(regi)), pm_taxCO2eq(t,regi));

pm_taxCO2eq(t,regi)$(t.val gt p45_lastNDCyear(regi))
   = (  !! regional, weight going from 1 in last NDC target year to 0 in 2100
        p45_taxCO2eqLastNDCyear(regi) * p45_taxCO2eqYearlyIncrease**(t.val-p45_lastNDCyear(regi)) * (max(p45_taxCO2eqConvergenceYear,t.val) - t.val)
        !! global, weight going from 0 in NDC target year to 1 in and after 2100
      + p45_taxCO2eqGlobal2030          * p45_taxCO2eqYearlyIncrease**(t.val-2030)                    * (min(p45_taxCO2eqConvergenceYear,t.val) - p45_lastNDCyear(regi))
      )/(p45_taxCO2eqConvergenceYear - p45_lastNDCyear(regi));

pm_taxCO2eq(t,regi) = max(pm_taxCO2eq(t,regi), p45_taxCO2eq_bau(t,regi));

display pm_taxCO2eq;

*#' @equations 
*#'  calculate level of emission target that it should converge to, composed of:
*#'  emission target relative to 2005 emissions (factor_targetyear) for part of region with NDC target
*#'  baseline for the rest of the countries
p45_CO2eqwoLU_goal(p45_NDCyearSet(t,regi)) =
          p45_2015shareTarget(t,regi)     * p45_BAU_reg_emi_wo_LU_wo_bunkers("2015",regi) * p45_factorTargetyear(t,regi)    !! share with NDC target
        + (1-p45_2015shareTarget(t,regi)) * p45_BAU_reg_emi_wo_LU_wo_bunkers(t,regi);            !! baseline for share of countries without NDC target

display pm_taxCO2eq,p45_CO2eqwoLU_goal;

*** EOF ./modules/45_carbonprice/NDC/preloop.gms
