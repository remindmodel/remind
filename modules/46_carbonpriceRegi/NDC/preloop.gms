*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/NDC/preloop.gms

*** first calculate tax path until last NDC target year - linear increase, set total tax to 30$/t for fully covered countries
pm_taxCO2eqRegi(ttot,regi)$(ttot.val gt 2016 AND ttot.val le p46_lastNDCyear(regi))
  = max(
        0.1 * sm_DptCO2_2_TDpGtC,
        (30 * p46_bestNDCcoverage(regi) - pm_taxCO2eq(ttot,regi)) * sm_DptCO2_2_TDpGtC
       )*(ttot.val-2015)/5;

*** convergence scheme after the last NDC target year: exponential increase AND regional convergence until p46_taxCO2eqConvergenceYear
*** note that with p46_taxCO2eqYearlyIncrease = 1 and p46_taxCO2eqGlobal2030, the tax decreases linearly to zero in 2100
p46_taxCO2eqLastNDCyear(regi) = smax(ttot$(ttot.val = p46_lastNDCyear(regi)), pm_taxCO2eqRegi(ttot,regi));

pm_taxCO2eqRegi(ttot,regi)$(ttot.val gt p46_lastNDCyear(regi))
   = (  !! regional, weight going from 1 in last NDC target year to 0 in 2100
        p46_taxCO2eqLastNDCyear(regi) * p46_taxCO2eqYearlyIncrease**(ttot.val-p46_lastNDCyear(regi)) * (max(p46_taxCO2eqConvergenceYear,ttot.val) - ttot.val)
        !! global, weight going from 0 in NDC target year to 1 in and after 2100
      + p46_taxCO2eqGlobal2030          * p46_taxCO2eqYearlyIncrease**(ttot.val-2030)                    * (min(p46_taxCO2eqConvergenceYear,ttot.val) - p46_lastNDCyear(regi))
      )/(p46_taxCO2eqConvergenceYear - p46_lastNDCyear(regi));

display pm_taxCO2eqRegi;

*** new 2020 carbon price definition: weighted average of 2015 and 2025, with triple weight for 2015 (which is zero for all non-eu regions).
pm_taxCO2eqRegi("2020",regi) = (3*pm_taxCO2eqRegi("2015",regi)+pm_taxCO2eqRegi("2025",regi))/4;

*#' @equations
*#'  calculate level of emission target that it should converge to, composed of:
*#'  emission target relative to 2005 emissions (factor_targetyear) for part of region with NDC target
*#'  baseline for the rest of the countries
p46_CO2eqwoLU_goal(p46_NDCyearSet(ttot,regi)) =
          p46_2005shareTarget(ttot,regi)     * p46_BAU_reg_emi_wo_LU_bunkers("2005",regi) * p46_factorTargetyear(ttot,regi)    !! share with NDC target
        + (1-p46_2005shareTarget(ttot,regi)) * p46_BAU_reg_emi_wo_LU_bunkers(ttot,regi);            !! baseline for share of countries without NDC target

display pm_taxCO2eqRegi,p46_CO2eqwoLU_goal;

*** EOF ./modules/46_carbonpriceRegi/NDC/preloop.gms
