*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/NDC/preloop.gms

*** first calculate tax path until last NDC target year - linear increase, set total tax to 30$/t for fully covered countries
pm_taxCO2eqRegi(t,regi)$(t.val gt 2016 AND t.val le p46_lastNDCyear(regi))
  = max(
        0.1 * sm_DptCO2_2_TDpGtC,
        (30 * p46_bestNDCcoverage(regi) * sm_DptCO2_2_TDpGtC - pm_taxCO2eq(t,regi))
       )*(t.val-2015)/5;

*** convergence scheme after the last NDC target year: exponential increase AND regional convergence until p46_taxCO2eqConvergenceYear
*** note that with p46_taxCO2eqYearlyIncrease = 1 and p46_taxCO2eqGlobal2030, the tax decreases linearly to zero in 2100
p46_taxCO2eqLastNDCyear(regi) = smax(t$(t.val = p46_lastNDCyear(regi)), pm_taxCO2eqRegi(t,regi));

pm_taxCO2eqRegi(t,regi)$(t.val gt p46_lastNDCyear(regi))
   = (  !! regional, weight going from 1 in last NDC target year to 0 in 2100
        p46_taxCO2eqLastNDCyear(regi) * p46_taxCO2eqYearlyIncrease**(t.val-p46_lastNDCyear(regi)) * (max(p46_taxCO2eqConvergenceYear,t.val) - t.val)
        !! global, weight going from 0 in NDC target year to 1 in and after 2100
      + p46_taxCO2eqGlobal2030          * p46_taxCO2eqYearlyIncrease**(t.val-2030)                * (min(p46_taxCO2eqConvergenceYear,t.val) - p46_lastNDCyear(regi))
      )/(p46_taxCO2eqConvergenceYear - p46_lastNDCyear(regi));

display pm_taxCO2eqRegi;

*#' @equations
*#'  calculate level of emission target that it should converge to, composed of:
*#'  emission target relative to 2005 emissions (factor_targetyear) for part of region with NDC target
*#'  baseline for the rest of the countries
p46_CO2eqwoLU_goal(p46_NDCyearSet(t,regi)) =
          p46_2015shareTarget(t,regi)     * p46_BAU_reg_emi_wo_LU_wo_bunkers("2015",regi) * p46_factorTargetyear(t,regi)    !! share with NDC target
        + (1-p46_2015shareTarget(t,regi)) * p46_BAU_reg_emi_wo_LU_wo_bunkers(t,regi);            !! baseline for share of countries without NDC target

display pm_taxCO2eqRegi,p46_CO2eqwoLU_goal;

*** EOF ./modules/46_carbonpriceRegi/NDC/preloop.gms
