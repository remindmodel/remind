*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDC/postsolve.gms

if(cm_iterative_target_adj eq 3,

display pm_taxCO2eq;

*#' @equations 
*#' calculate emission variable to be used for NDC target: GHG emissions w/o land-use change and w/o transport bunker emissions, unit [Mt CO2eq/yr]
p45_CO2eqwoLU_actual(p45_NDCyearSet(t,regi)) =
    vm_co2eq.l(t,regi) * sm_c_2_co2*1000
*** add F-Gases
    + vm_emiFgas.L(t,regi,"emiFgasTotal")
*** substract bunker emissions
    - sum(se2fe(enty,enty2,te),
        pm_emifac(t,regi,enty,enty2,te,"co2")
        * vm_demFeSector.l(t,regi,enty,enty2,"trans","other") * sm_c_2_co2 * 1000
      ); 

pm_taxCO2eq_iter(iteration,p45_NDCyearSet(t,regi)) = pm_taxCO2eq(t,regi);
p45_CO2eqwoLU_actual_iter(iteration,p45_NDCyearSet(t,regi)) = p45_CO2eqwoLU_actual(t,regi);

display vm_co2eq.l;
display p45_CO2eqwoLU_actual;
display p45_CO2eqwoLU_goal;

*#' nash compatible convergence scheme: adjustment of co2 tax for next iteration based on deviation of emissions in this iteration (actual) from target emissions (ref)
*#' maximum possible change between iterations decreases with increase of iteration number

if(       iteration.val lt  8, p45_adjustExponent = 4;
   elseif iteration.val lt 15, p45_adjustExponent = 3;
   elseif iteration.val lt 23, p45_adjustExponent = 2;
   else                        p45_adjustExponent = 1;
);

p45_factorRescaleCO2Tax(p45_NDCyearSet(t,regi)) =
  ( (p45_CO2eqwoLU_actual(t,regi)+0.0001)/(p45_CO2eqwoLU_goal(t,regi)+0.0001) )**p45_adjustExponent;

p45_factorRescaleCO2TaxLtd(p45_NDCyearSet(t,regi)) =
  min(max(0.1**p45_adjustExponent, p45_factorRescaleCO2Tax(t,regi)), max(2-iteration.val/15,1.01-iteration.val/10000));
*** use max(0.1, ...) to make sure that negative emission values cause no problem, use +0.0001 such that net zero targets cause no problem

pm_taxCO2eq(t,regi)$(t.val gt 2021 AND t.val le p45_lastNDCyear(regi)) = max(1* sm_DptCO2_2_TDpGtC,pm_taxCO2eq(t,regi) * p45_factorRescaleCO2TaxLtd(t,regi) );

p45_factorRescaleCO2Tax_iter(iteration,t,regi) = p45_factorRescaleCO2Tax(t,regi);
p45_factorRescaleCO2TaxLtd_iter(iteration,t,regi) = p45_factorRescaleCO2TaxLtd(t,regi);

display p45_factorRescaleCO2TaxLtd_iter;

*** calculate tax path until NDC target year - linear increase
p45_taxCO2eqFirstNDCyear(regi) = smax(t$(t.val = p45_firstNDCyear(regi)), pm_taxCO2eq(t,regi));
pm_taxCO2eq(t,regi)$(t.val > 2021 AND t.val < p45_firstNDCyear(regi)) = (p45_taxCO2eqFirstNDCyear(regi) - pm_taxCO2eq("2020",regi))*(t.val-2020)/(p45_firstNDCyear(regi)-2020) + pm_taxCO2eq("2020",regi);

*** replace taxCO2eq between NDC targets such that taxCO2eq between goals does not decrease
loop( p45_NDCyearSet(t2,regi) ,
  pm_taxCO2eq(t,regi)$(t.val > t2.val AND not p45_NDCyearSet(t,regi)) = pm_taxCO2eq(t2,regi);
) ;

*** convergence scheme post NDC target year: exponential increase AND regional convergence until p45_taxCO2eqConvergenceYear
p45_taxCO2eqLastNDCyear(regi) = smax(t$(t.val = p45_lastNDCyear(regi)), pm_taxCO2eq(t,regi));

pm_taxCO2eq(t,regi)$(t.val gt p45_lastNDCyear(regi))
   = (  !! regional, weight going from 1 in NDC target year to 0  in 2100
        p45_taxCO2eqLastNDCyear(regi) * p45_taxCO2eqYearlyIncrease**(t.val-p45_lastNDCyear(regi)) * (max(p45_taxCO2eqConvergenceYear,t.val) - t.val)
        !! global, weight going from 0 in NDC target year to 1 in and after 2100
      + p45_taxCO2eqGlobal2030        * p45_taxCO2eqYearlyIncrease**(t.val-2030)                  * (min(t.val,p45_taxCO2eqConvergenceYear) - p45_lastNDCyear(regi))
      )/(p45_taxCO2eqConvergenceYear - p45_lastNDCyear(regi));

***as a minimum, use BAU and have linear price increase starting from 1$ in 2030
pm_taxCO2eq(t,regi)$(t.val ge 2030) = max(
                 pm_taxCO2eq(t,regi),
                 p45_taxCO2eq_bau(t,regi),
                 1 * sm_DptCO2_2_TDpGtC * (1+(t.val-2030)*9/7), p45_taxCO2eq_bau(t,regi)
  );

display pm_taxCO2eq;

*** end if from beginning of file (cm_iterative_target_adj eq 3)
);

*** EOF ./modules/45_carbonprice/NDC/postsolve.gms
