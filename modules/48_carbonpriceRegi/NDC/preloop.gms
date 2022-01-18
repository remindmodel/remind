*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/48_carbonpriceRegi/NDC/preloop.gms

*** first calculate tax path until last NDC target year - linear increase
pm_taxCO2eq_regi(ttot,regi)$(ttot.val gt 2016 AND ttot.val le p48_last_NDC_year(regi)) = pm_taxCO2eq("2020",regi)*(ttot.val-2015)/5;

*** convergence scheme after the last NDC target year: exponential increase AND regional convergence until p48_taxCO2eq_convergence_year
*** note that with p48_taxCO2eq_yearly_increase = 1 and p48_taxCO2eq_global2030, the tax decreases linearly to zero in 2100
p48_taxCO2eq_last_NDC_year(regi) = smax(ttot$(ttot.val = p48_last_NDC_year(regi)), pm_taxCO2eq_regi(ttot,regi));

pm_taxCO2eq_regi(ttot,regi)$(ttot.val gt p48_last_NDC_year(regi))
   = (  !! regional, weight going from 1 in last NDC target year to 0 in 2100
        p48_taxCO2eq_last_NDC_year(regi) * p48_taxCO2eq_yearly_increase**(ttot.val-p48_last_NDC_year(regi)) * (max(p48_taxCO2eq_convergence_year,ttot.val) - ttot.val)
        !! global, weight going from 0 in NDC target year to 1 in and after 2100
      + p48_taxCO2eq_global2030          * p48_taxCO2eq_yearly_increase**(ttot.val-2030)                    * (min(p48_taxCO2eq_convergence_year,ttot.val) - p48_last_NDC_year(regi))
      )/(p48_taxCO2eq_convergence_year - p48_last_NDC_year(regi));

display pm_taxCO2eq_regi;

*** new 2020 carbon price definition: weighted average of 2015 and 2025, with triple weight for 2015 (which is zero for all non-eu regions).
pm_taxCO2eq_regi("2020",regi) = (3*pm_taxCO2eq_regi("2015",regi)+pm_taxCO2eq_regi("2025",regi))/4;

*#' @equations 
*#'  calculate level of emission target that it should converge to, composed of:
*#'  emission target relative to 2005 emissions (factor_targetyear) for part of region with NDC target
*#'  baseline for the rest of the countries
p48_ref_co2eq_woLU_regi(p48_NDC_year_set(ttot,regi)) = 
          p48_2005share_target(ttot,regi)     * p48_BAU_reg_emi_wo_LU_bunkers("2005",regi) * p48_factor_targetyear(ttot,regi)    !! share with NDC target
        + (1-p48_2005share_target(ttot,regi)) * p48_BAU_reg_emi_wo_LU_bunkers(ttot,regi);            !! baseline for share of countries without NDC target

display pm_taxCO2eq_regi,p48_ref_co2eq_woLU_regi;
*** EOF ./modules/48_carbonpriceRegi/NDC/preloop.gms
