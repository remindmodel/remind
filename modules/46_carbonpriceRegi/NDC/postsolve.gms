*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/NDC/postsolve.gms

if(sameas("%carbonprice%","none"), p46_startInIteration = 0);

if(ord(iteration) > p46_startInIteration, !!start only after p46_startInIteration iterations, so to already have some stability of the overall carbon price trajectory

*#' @equations
*#' calculate emission variable to be used for NDC target: GHG emissions w/o land-use change and w/o transport bunker emissions, unit [Mt CO2eq/yr]
p46_CO2eqwoLU_actual(p46_NDCyearSet(ttot,regi)) =
    vm_co2eq.l(ttot,regi) * sm_c_2_co2*1000
*** add F-Gases
    + vm_emiFgas.L(ttot,regi,"emiFgasTotal")
*** substract bunker emissions
    - sum(se2fe(enty,enty2,te),
        pm_emifac(ttot,regi,enty,enty2,te,"co2")
        * vm_demFeSector.l(ttot,regi,enty,enty2,"trans","other") * sm_c_2_co2 * 1000
      );

*** there is some debate whether Chinas net zero goal is not CO2eq, but CO2. Then use CO2 emissions minus substract bunker emissions
*** p46_CO2eqwoLU_actual(p46_NDCyearSet(ttot,regi))$(sameas(regi,"CHA") AND sameas(ttot,"2055")) =
***  (vm_emiTe.l(ttot,regi,"co2") + vm_emiMac.L(ttot,regi,"co2") + vm_emiCdr.L(ttot,regi,"co2"))*sm_c_2_co2*1000
***    - sum(se2fe(enty,enty2,te),
***        pm_emifac(ttot,regi,enty,enty2,te,"co2")
***        * vm_demFeSector.l(ttot,regi,enty,enty2,"trans","other") * sm_c_2_co2 * 1000
***      );

display vm_co2eq.l;
display p46_CO2eqwoLU_actual;
display p46_CO2eqwoLU_goal;

*#' calculate emissions in 2020 as reference
p46_vm_co2eq_2020(regi) = vm_co2eq.l("2020",regi)*sm_c_2_co2*1000;

*#' nash compatible convergence scheme: adjustment of co2 tax for next iteration based on deviation of emissions in this iteration (actual) from target emissions (ref)
*#' maximum possible change between iterations decreases with increase of iteration number

*** rescale regi tax by comparing the required emission reduction with 2020 emission levels
p46_factorRescaleCO2Tax(p46_NDCyearSet(t,regi)) = 1+(p46_CO2eqwoLU_actual(t,regi) - p46_CO2eqwoLU_goal(t,regi))/p46_vm_co2eq_2020(regi);

p46_factorRescaleCO2TaxLtd(p46_NDCyearSet(t,regi)) =
  min(
*** sets upper bound that decreases with iterations
     max(2-(iteration.val-p46_startInIteration)/15,1.01-(iteration.val-p46_startInIteration)/10000),
*** sets lower bound of 0.1
     max(0.1, p46_factorRescaleCO2Tax(t,regi)
  ));

***  min((( max(0.1, (p46_CO2eqwoLU_actual(t,regi)+0.0001)/(p46_CO2eqwoLU_goal(t,regi)+0.0001) ) )**p46_adjustExponent),max(2-(iteration.val-p46_startInIteration)/15,1.01-(iteration.val-p46_startInIteration)/10000));
*** use max(0.1, ...) to make sure that negative emission values cause no problem, use +0.0001 such that net zero targets cause no problem

pm_taxCO2eqRegi(p46_NDCyearSet(t,regi)) =
  max(
      !! set lower bound of 0.1 $/t to avoid that the model never gets the carbon price back up
      0.1 * sm_DptCO2_2_TDpGtC,
      !! set regi tax such that total CO2 tax changes by desired factor, taking into account changed pm_taxCO2eq taxes
      p46_factorRescaleCO2TaxLtd(t,regi) * (pm_taxCO2eqRegi(t,regi) + p46_taxCO2eqLast(t,regi))
      - pm_taxCO2eq(t,regi)
     );

p46_previousYearInLoop = 2020;

*** interpolate taxCO2eq linearly from 0 in 2020 to first NDC target and between NDC targets
loop(regi,
  p46_previousYearInLoop = 2020;
  p46_taxPreviousYearInLoop = smax(ttot$(ttot.val = p46_previousYearInLoop), pm_taxCO2eqRegi(ttot,regi) );
  loop(p46_NDCyearSet(t,regi) ,
    pm_taxCO2eqRegi(ttot,regi)$(ttot.val > p46_previousYearInLoop AND ttot.val < t.val)
      = p46_taxPreviousYearInLoop + (ttot.val - p46_previousYearInLoop) * (pm_taxCO2eqRegi(t,regi) - p46_taxPreviousYearInLoop)/(t.val - p46_previousYearInLoop);
    p46_previousYearInLoop = t.val;
    p46_taxPreviousYearInLoop = smax(ttot$(ttot.val = p46_previousYearInLoop), pm_taxCO2eqRegi(ttot,regi) );
  );
);

*** convergence scheme after last NDC target year: exponential increase AND regional convergence until p46_taxCO2eqConvergenceYear
p46_taxCO2eqLastNDCyear(regi) = smax(t$(t.val = p46_lastNDCyear(regi)), pm_taxCO2eqRegi(t,regi));

pm_taxCO2eqRegi(t,regi)$(t.val gt p46_lastNDCyear(regi))
   = (  !! regional, weight going from 1 in NDC target year to 0 in 2100
        p46_taxCO2eqLastNDCyear(regi) * p46_taxCO2eqYearlyIncrease**(t.val-p46_lastNDCyear(regi)) * (max(p46_taxCO2eqConvergenceYear,t.val) - t.val)
        !! global, weight going from 0 in NDC target year to 1 in and after 2100
      + p46_taxCO2eqGlobal2030          * p46_taxCO2eqYearlyIncrease**(t.val-2030)                    * (min(t.val,p46_taxCO2eqConvergenceYear) - p46_lastNDCyear(regi))
      )/(p46_taxCO2eqConvergenceYear - p46_lastNDCyear(regi));


display p46_factorRescaleCO2TaxLtd, pm_taxCO2eqRegi;

p46_factorRescaleCO2Tax_iter(iteration,p46_NDCyearSet(t,regi)) = p46_factorRescaleCO2Tax(t,regi);
p46_factorRescaleCO2TaxLtd_iter(iteration,p46_NDCyearSet(t,regi)) = p46_factorRescaleCO2TaxLtd(t,regi);


); !! end ord(iteration) > p46_startInIteration

p46_taxCO2eqLast(t,regi) = pm_taxCO2eq(t,regi);

p46_taxCO2eqRegi_iter(iteration,p46_NDCyearSet(t,regi)) = pm_taxCO2eqRegi(t,regi);
p46_taxCO2eq_iter(iteration,p46_NDCyearSet(t,regi)) = pm_taxCO2eq(t,regi);
p46_vm_co2eq_iter(iteration,p46_NDCyearSet(t,regi)) = vm_co2eq.l(t,regi);

*** EOF ./modules/46_carbonpriceRegi/NDC/postsolve.gms
