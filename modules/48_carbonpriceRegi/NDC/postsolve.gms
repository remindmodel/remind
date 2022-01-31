*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/48_carbonpriceRegi/NDC/postsolve.gms

if(ord(iteration)>10, !!start only after 10 iterations, so to already have some stability of the overall carbon price trajectory

*#' @equations
*#' calculate emission variable to be used for NDC target: GHG emissions w/o land-use change and w/o transport bunker emissions, unit [Mt CO2eq/yr]
p48_CO2eqwoLU_actual(p48_NDCyearSet(ttot,regi)) =
    vm_co2eq.l(ttot,regi) * sm_c_2_co2*1000
*** add F-Gases
    + vm_emiFgas.L(ttot,regi,"emiFgasTotal")
*** substract bunker emissions
    - sum(se2fe(enty,enty2,te),
        pm_emifac(ttot,regi,enty,enty2,te,"co2")
        * vm_demFeSector.l(ttot,regi,enty,enty2,"trans","other") * sm_c_2_co2 * 1000
      );


display vm_co2eq.l;
display p48_CO2eqwoLU_actual;
display p48_CO2eqwoLU_goal;

*#' calculate emissions in 2020 as reference
p48_vm_co2eq_2020(regi) = vm_co2eq.l("2020",regi)*sm_c_2_co2*1000;

*#' nash compatible convergence scheme: adjustment of co2 tax for next iteration based on deviation of emissions in this iteration (actual) from target emissions (ref)
*#' maximum possible change between iterations decreases with increase of iteration number

*** currently not used!
if(       iteration.val-10 lt  8, p48_adjustExponent = 4;
   elseif iteration.val-10 lt 15, p48_adjustExponent = 3;
   elseif iteration.val-10 lt 23, p48_adjustExponent = 2;
   else                           p48_adjustExponent = 1;
);

*** rescale regi tax by comparing the required emission reduction with 2020 emission levels
p48_factorRescaleCO2Tax(p48_NDCyearSet(t,regi)) = 1+(p48_CO2eqwoLU_actual(t,regi) - p48_CO2eqwoLU_goal(t,regi))/p48_vm_co2eq_2020(regi);

p48_factorRescaleCO2TaxLimited(p48_NDCyearSet(t,regi)) =
  min(
*** sets upper bound that decreases with iterations
     max(2-(iteration.val-10)/15,1.01-(iteration.val-10)/10000),
*** sets lower bound of 0.1
     max(0.1, p48_factorRescaleCO2Tax(t,regi)
  ));

***  min((( max(0.1, (p48_CO2eqwoLU_actual(t,regi)+0.0001)/(p48_CO2eqwoLU_goal(t,regi)+0.0001) ) )**p48_adjustExponent),max(2-(iteration.val-10)/15,1.01-(iteration.val-10)/10000));
*** use max(0.1, ...) to make sure that negative emission values cause no problem, use +0.0001 such that net zero targets cause no problem

pm_taxCO2eqRegi(p48_NDCyearSet(t,regi)) =
  max(
      !! set lower bound of 0.1 $/t to avoid that the model never gets the carbon price back up
      0.1 * sm_DptCO2_2_TDpGtC,
      !! set regi tax such that total CO2 tax changes by desired factor, taking into account changed pm_taxCO2eq taxes
      p48_factorRescaleCO2TaxLimited(t,regi) * (pm_taxCO2eqRegi(t,regi) + p48_taxCO2eqLast(t,regi))
      - pm_taxCO2eq(t,regi)
     );

p48_previousYearInLoop = 2020;

*** interpolate taxCO2eq linearly from 0 in 2020 to first NDC target and between NDC targets
loop(regi,
  p48_previousYearInLoop = 2020;
  p48_taxPreviousYearInLoop = smax(ttot$(ttot.val = p48_previousYearInLoop), pm_taxCO2eqRegi(ttot,regi) );
  loop(p48_NDCyearSet(t,regi) ,
    pm_taxCO2eqRegi(ttot,regi)$(ttot.val > p48_previousYearInLoop AND ttot.val < t.val)
      = p48_taxPreviousYearInLoop + (ttot.val - p48_previousYearInLoop) * (pm_taxCO2eqRegi(t,regi) - p48_taxPreviousYearInLoop)/(t.val - p48_previousYearInLoop);
    p48_previousYearInLoop = t.val;
    p48_taxPreviousYearInLoop = smax(ttot$(ttot.val = p48_previousYearInLoop), pm_taxCO2eqRegi(ttot,regi) );
  );
);

*** convergence scheme after last NDC target year: exponential increase AND regional convergence until p48_taxCO2eq_convergence_year
p48_taxCO2eqLastNDCyear(regi) = smax(t$(t.val = p48_lastNDCyear(regi)), pm_taxCO2eqRegi(t,regi));

pm_taxCO2eqRegi(t,regi)$(t.val gt p48_lastNDCyear(regi))
   = (  !! regional, weight going from 1 in NDC target year to 0 in 2100
        p48_taxCO2eqLastNDCyear(regi) * p48_taxCO2eq_yearly_increase**(t.val-p48_lastNDCyear(regi)) * (max(p48_taxCO2eq_convergence_year,t.val) - t.val)
        !! global, weight going from 0 in NDC target year to 1 in and after 2100
      + p48_taxCO2eq_global2030          * p48_taxCO2eq_yearly_increase**(t.val-2030)                    * (min(t.val,p48_taxCO2eq_convergence_year) - p48_lastNDCyear(regi))
      )/(p48_taxCO2eq_convergence_year - p48_lastNDCyear(regi));


display p48_factorRescaleCO2TaxLimited, pm_taxCO2eqRegi;

p48_factorRescaleCO2TaxTrack(iteration,p48_NDCyearSet(t,regi)) = p48_factorRescaleCO2Tax(t,regi);
p48_factorRescaleCO2TaxLtdTrack(iteration,p48_NDCyearSet(t,regi)) = p48_factorRescaleCO2TaxLimited(t,regi);


); !! end ord(iteration) > 10

p48_taxCO2eqLast(t,regi) = pm_taxCO2eq(t,regi);

p48_taxCO2eqRegiTrack(iteration,p48_NDCyearSet(t,regi)) = pm_taxCO2eqRegi(t,regi);
p48_taxCO2eqTrack(iteration,p48_NDCyearSet(t,regi)) = pm_taxCO2eq(t,regi);

*** EOF ./modules/48_carbonpriceRegi/NDC/postsolve.gms
