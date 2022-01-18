*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/48_carbonpriceRegi/NDC/postsolve.gms

if(ord(iteration)>10, !!start only after 10 iterations, so to already have some stability of the overall carbon price trajectory

    display pm_taxCO2eq, pm_taxCO2eq_regi;

*#' @equations 
*#' calculate emission variable to be used for NDC target: GHG emissions w/o land-use change and w/o transport bunker emissions, unit [Mt CO2eq/yr]
p48_actual_co2eq_woLU_regi(p48_NDC_year_set(ttot,regi)) =
    vm_co2eq.l(ttot,regi) * sm_c_2_co2*1000
*** add F-Gases
    + vm_emiFgas.L(ttot,regi,"emiFgasTotal")
*** substract bunker emissions
    - sum(se2fe(enty,enty2,te),
        pm_emifac(ttot,regi,enty,enty2,te,"co2")
        * vm_demFeSector.l(ttot,regi,enty,enty2,"trans","other") * sm_c_2_co2 * 1000
      ); 


display vm_co2eq.l;
display p48_actual_co2eq_woLU_regi;
display p48_ref_co2eq_woLU_regi;

*#' nash compatible convergence scheme: adjustment of co2 tax for next iteration based on deviation of emissions in this iteration (actual) from target emissions (ref)
*#' maximum possible change between iterations decreases with increase of iteration number

if(       iteration.val-10 lt  8, p48_adjust_exponent = 4;
   elseif iteration.val-10 lt 15, p48_adjust_exponent = 3;
   elseif iteration.val-10 lt 23, p48_adjust_exponent = 2;
   else                           p48_adjust_exponent = 1;
);

p48_factorRescaleCO2Tax(p48_NDC_year_set(ttot,regi)) =
  min((( max(0.1, (p48_actual_co2eq_woLU_regi(ttot,regi)+0.0001)/(p48_ref_co2eq_woLU_regi(ttot,regi)+0.0001) ) )**p48_adjust_exponent),max(2-(iteration.val-10)/15,1.01-(iteration.val-10)/10000));
*** use max(0.1, ...) to make sure that negative emission values cause no problem, use +0.0001 such that net zero targets cause no problem

pm_taxCO2eq_regi(p48_NDC_year_set(t,regi)) = max(1* sm_DptCO2_2_TDpGtC,pm_taxCO2eq_regi(t,regi) * p48_factorRescaleCO2Tax(t,regi) );
p48_factorRescaleCO2TaxTrack(iteration,ttot,regi) = p48_factorRescaleCO2Tax(ttot,regi);

display p48_factorRescaleCO2TaxTrack;

p48_previous_year_in_loop = 2015;

*** interpolate taxCO2eq linearly from 0 in 2015 to first NDC target and between NDC targets
loop(regi,
  p48_previous_year_in_loop = 2015;
  p48_tax_previous_year_in_loop = smax(ttot$(ttot.val = p48_previous_year_in_loop), pm_taxCO2eq_regi(ttot,regi) );
  loop(p48_NDC_year_set(ttot2,regi) ,
    pm_taxCO2eq_regi(ttot,regi)$(ttot.val > p48_previous_year_in_loop AND ttot.val < ttot2.val)
      = p48_tax_previous_year_in_loop + (ttot.val - p48_previous_year_in_loop) * (pm_taxCO2eq_regi(ttot2,regi) - p48_tax_previous_year_in_loop)/(ttot2.val - p48_previous_year_in_loop);
    p48_previous_year_in_loop = ttot2.val;
    p48_tax_previous_year_in_loop = smax(ttot$(ttot.val = p48_previous_year_in_loop), pm_taxCO2eq_regi(ttot,regi) );
  );
);

*** convergence scheme after last NDC target year: exponential increase AND regional convergence until p48_taxCO2eq_convergence_year
p48_taxCO2eq_last_NDC_year(regi) = smax(ttot$(ttot.val = p48_last_NDC_year(regi)), pm_taxCO2eq_regi(ttot,regi));

pm_taxCO2eq_regi(ttot,regi)$(ttot.val gt p48_last_NDC_year(regi))
   = (  !! regional, weight going from 1 in NDC target year to 0  in 2100
        p48_taxCO2eq_last_NDC_year(regi) * p48_taxCO2eq_yearly_increase**(ttot.val-p48_last_NDC_year(regi)) * (max(p48_taxCO2eq_convergence_year,ttot.val) - ttot.val)
        !! global, weight going from 0 in NDC target year to 1 in and after 2100
      + p48_taxCO2eq_global2030          * p48_taxCO2eq_yearly_increase**(ttot.val-2030)                    * (min(ttot.val,p48_taxCO2eq_convergence_year) - p48_last_NDC_year(regi))
      )/(p48_taxCO2eq_convergence_year - p48_last_NDC_year(regi));


        display pm_taxCO2eq_regi;
); !! end ord(iterations) > 10

*** EOF ./modules/48_carbonpriceRegi/NDC/postsolve.gms
